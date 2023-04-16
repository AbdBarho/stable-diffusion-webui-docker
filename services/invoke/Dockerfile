FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/5.0.0/xformers-0.0.17.dev449-cp310-cp310-manylinux2014_x86_64.whl'



FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1


RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.1+cu117 torchvision --extra-index-url https://download.pytorch.org/whl/cu117


# patch match:
# https://github.com/invoke-ai/InvokeAI/blob/main/docs/installation/INSTALL_PATCHMATCH.md
RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get install make g++ git libopencv-dev -y && \
  apt-get clean && \
  cd /usr/lib/x86_64-linux-gnu/pkgconfig/ && \
  ln -sf opencv4.pc opencv.pc



ENV ROOT=/InvokeAI
RUN git clone https://github.com/invoke-ai/InvokeAI.git ${ROOT}
WORKDIR ${ROOT}

RUN --mount=type=cache,target=/root/.cache/pip \
  git reset --hard 4463124bddd221c333d4c70e73aa2949ad35453d && \
  pip install .


ARG BRANCH=main SHA=50eb02f68be912276a9c106d5e8038a5671a0386
RUN --mount=type=cache,target=/root/.cache/pip \
  git fetch && \
  git reset --hard && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -U .

RUN --mount=type=cache,target=/root/.cache/pip \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.17-cp310-cp310-linux_x86_64.whl \
  pip install -U opencv-python-headless triton /xformers-0.0.17-cp310-cp310-linux_x86_64.whl && \
  python3 -c "from patchmatch import patch_match"


COPY . /docker/

ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENV PYTHONUNBUFFERED=1 PRELOAD=false HF_HOME=/root/.cache/huggingface CONFIG_DIR=/data/config/invoke CLI_ARGS=""
EXPOSE 7860

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD invokeai --web --host 0.0.0.0 --port 7860 --root_dir ${ROOT} --config ${CONFIG_DIR}/models.yaml --outdir /output/invoke ${CLI_ARGS}
# TODO: make sure the config is persisted between sessions
