FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/6.0.0/xformers-0.0.21.dev544-cp310-cp310-manylinux2014_x86_64-pytorch201.whl'

FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git && apt-get clean

# add in required packages
RUN apt-get install 'libglib2.0-0'  -y
RUN apt-get install 'libgl1-mesa-glx' -y
RUN apt-get install 'python-dev' -y

# set this to your target branch commit
ARG BRANCH=main SHA=d7439b2d6004d50a0fda19108603a8d1941a185e

ENV ROOT=/stable-diffusion
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/lllyasviel/Fooocus.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements_versions.txt


RUN --mount=type=cache,target=/root/.cache/pip  \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.21-cp310-cp310-linux_x86_64.whl \
  pip install /xformers-0.0.21-cp310-cp310-linux_x86_64.whl

WORKDIR ${ROOT}

RUN --mount=type=cache,target=/root/.cache/pip \
  git fetch && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements_versions.txt

# add info
COPY . /docker/
RUN cp /docker/config.txt ${ROOT}
RUN chmod u+x /docker/entrypoint.sh

EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u entry_with_update.py --listen --port 7860 ${CLI_ARGS}
