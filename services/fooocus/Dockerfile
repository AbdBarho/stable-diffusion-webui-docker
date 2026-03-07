FROM alpine:3.17 as xformers
RUN apk add --no-cache aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/6.0.0/xformers-0.0.21.dev544-cp310-cp310-manylinux2014_x86_64-pytorch201.whl'

FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git libglib2.0-0 libgl1-mesa-glx python-dev libgoogle-perftools-dev && apt-get clean

ARG PUID=0
ARG PGID=0
ARG USER_HOME=/root
# set build args as container environment variables for entrypoint reference
ENV PUID=$PUID
ENV PGID=$PGID
ENV USER_HOME=$USER_HOME

# if user home does not exist, create it
RUN mkdir -p "$USER_HOME"

# home already exists, chown it
RUN chown -R "${PUID}:${PGID}" "$USER_HOME"

# Only groupadd if we're non root
RUN if [ "$PGID" -ne "0" ]; then \
      echo non root group detected; \
      groupadd \
        --gid "$PGID" \
        stablediffusion ;\
    else \
      echo "root group detected" ; \
    fi

# Only useradd if we're non root
RUN if [ "$PUID" -ne "0" ]; then \
      echo non root user detected; \
      useradd \
        --gid="$PGID" \
        --no-user-group \
        -M \
        --home "$USER_HOME" \
        stablediffusion ; \
    else \
      echo "root group detected" ; \
    fi

# set this to your target branch commit
ARG BRANCH=main SHA=e2f9bcb11d06216d6800676c48d8d74d6fd77a4b

ENV ROOT=/stable-diffusion


# drop permissions (if build targets non root)
USER $PUID:$PGID

RUN --mount=type=cache,target=${USER_HOME}/.cache/pip \
  git clone https://github.com/lllyasviel/Fooocus.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements_versions.txt

RUN chown -R "$PUID:$PGID" "${ROOT}"

RUN --mount=type=cache,target=${USER_HOME}/.cache/pip  \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.21-cp310-cp310-linux_x86_64.whl \
  pip install /xformers-0.0.21-cp310-cp310-linux_x86_64.whl

WORKDIR ${ROOT}

RUN --mount=type=cache,target=${USER_HOME}/.cache/pip \
  git fetch && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements_versions.txt

# add info
COPY --chown=$PUID:$PGID . /docker
RUN cp /docker/config.txt ${ROOT}
RUN chmod u+x /docker/entrypoint.sh

EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u entry_with_update.py --listen --port 7860 ${CLI_ARGS}
