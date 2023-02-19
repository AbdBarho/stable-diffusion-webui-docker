# syntax=docker/dockerfile:1

FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/5.0.0/xformers-0.0.17.dev449-cp310-cp310-manylinux2014_x86_64.whl'



FROM python:3.10-slim
SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1


RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.1+cu117 torchvision --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt-get install git -y && apt-get clean

RUN git clone https://github.com/invoke-ai/InvokeAI.git /stable-diffusion

WORKDIR /stable-diffusion

RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git reset --hard f232068ab89bd80e4f5f3133dcdb62ea78f1d0f7
git config --global http.postBuffer 1048576000
egrep -v '^-e .' environments-and-requirements/requirements-lin-cuda.txt > req.txt
pip install -r req.txt
rm req.txt
EOF


# patch match:
# https://github.com/invoke-ai/InvokeAI/blob/main/docs/installation/INSTALL_PATCHMATCH.md
RUN <<EOF
apt-get update
# apt-get install build-essential python3-opencv libopencv-dev -y
apt-get install make g++ libopencv-dev -y
apt-get clean
cd /usr/lib/x86_64-linux-gnu/pkgconfig/
ln -sf opencv4.pc opencv.pc
EOF


ARG BRANCH=main SHA=d3c1b747ee1632c6fab81ba9f89314e9fbdd55e4
RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
pip install .
EOF


RUN --mount=type=cache,target=/root/.cache/pip \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.15-cp310-cp310-linux_x86_64.whl \
  pip install -U opencv-python-headless huggingface_hub triton /xformers-0.0.15-cp310-cp310-linux_x86_64.whl && \
  python3 -c "from patchmatch import patch_match"


RUN touch invokeai.init
COPY . /docker/


ENV PYTHONUNBUFFERED=1 ROOT=/stable-diffusion PYTHONPATH="${PYTHONPATH}:${ROOT}" PRELOAD=false CLI_ARGS="" HF_HOME=/root/.cache/huggingface
EXPOSE 7860

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD invokeai --web --host 0.0.0.0 --port 7860 --config /docker/models.yaml --root_dir ${ROOT} --outdir /output/invoke ${CLI_ARGS}
