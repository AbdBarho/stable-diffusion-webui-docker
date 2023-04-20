FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/5.0.0/xformers-0.0.17.dev449-cp310-cp310-manylinux2014_x86_64.whl'

FROM python:3.10.10-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.1+cu117 torchvision --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt-get install -y git && apt-get clean

RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git stable-diffusion && \
  cd stable-diffusion && \
  git checkout master && \
  git reset --hard 884ea653c8d6fe19b3724f45a04a0d74cd881f2f && \
  pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip  \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.15-cp310-cp310-linux_x86_64.whl \
  pip install triton /xformers-0.0.15-cp310-cp310-linux_x86_64.whl

ARG BRANCH=master SHA=884ea653c8d6fe19b3724f45a04a0d74cd881f2f
RUN --mount=type=cache,target=/root/.cache/pip \
  cd stable-diffusion && \
  git fetch && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip pip install -U 'transformers>=4.24'

# add info
COPY . /docker/
RUN chmod +x /docker/entrypoint.sh

WORKDIR /stable-diffusion
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
