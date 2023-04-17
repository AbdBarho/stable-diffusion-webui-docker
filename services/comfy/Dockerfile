FROM python:3.10.9-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.0 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt-get install -y git && apt-get clean

ARG BRANCH=master
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git stable-diffusion && \
  cd stable-diffusion && \
  git checkout ${BRANCH} && \
  git reset --hard ee46bef03a98903831c01d31094a0c30ea411b28 && \
  pip install -r requirements.txt

ARG SHA=
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
