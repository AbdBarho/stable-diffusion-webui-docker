FROM python:3.10.9-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.0 torchvision --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt-get install -y git && apt-get clean

RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git stable-diffusion && \
  cd stable-diffusion && \
  git checkout master && \
  git reset --hard 884ea653c8d6fe19b3724f45a04a0d74cd881f2f && \
  pip install -r requirements.txt

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
