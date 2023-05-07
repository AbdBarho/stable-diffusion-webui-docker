FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/5.0.3/xformers-0.0.20.dev528-cp310-cp310-manylinux2014_x86_64-pytorch2.whl'


FROM python:3.10.9-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git aria2 && apt-get clean

RUN --mount=type=cache,target=/cache --mount=type=cache,target=/root/.cache/pip \
  aria2c -x 5 --dir /cache --out torch-2.0.0-cp310-cp310-linux_x86_64.whl -c \
  https://download.pytorch.org/whl/cu118/torch-2.0.0%2Bcu118-cp310-cp310-linux_x86_64.whl && \
  pip install /cache/torch-2.0.0-cp310-cp310-linux_x86_64.whl torchvision --index-url https://download.pytorch.org/whl/cu118

ENV ROOT=/stable-diffusion
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout master && \
  git reset --hard 884ea653c8d6fe19b3724f45a04a0d74cd881f2f && \
  pip install -r requirements.txt


RUN --mount=type=cache,target=/root/.cache/pip  \
--mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.20.dev528-cp310-cp310-manylinux2014_x86_64.whl \
pip install /xformers-0.0.20.dev528-cp310-cp310-manylinux2014_x86_64.whl


WORKDIR ${ROOT}

ARG BRANCH=master SHA=cb1551b819ecaa7d9044c13d0c8e8cfa4ff72830
RUN --mount=type=cache,target=/root/.cache/pip \
  git fetch && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements.txt

# add info
COPY . /docker/
RUN cp /docker/extra_model_paths.yaml ${ROOT}
RUN chmod u+x /docker/entrypoint.sh

ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility NVIDIA_VISIBLE_DEVICES=all
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
