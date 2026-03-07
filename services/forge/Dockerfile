FROM alpine/git:2.36.2 AS download

COPY clone.sh /clone.sh

RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
RUN . /clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f
RUN . /clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git 6f7db241d2f8ba7457bac5ca9753331f0c266917
RUN . /clone.sh huggingface_guess https://github.com/lllyasviel/huggingface_guess.git 70942022b6bcd17d941c1b4172804175758618e2


FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/apt \
  apt-get update && \
  # we need those
  apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
  # extensions needs those
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential libgoogle-perftools-dev && \
  apt-get clean

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

ENV ROOT=/stable-diffusion-webui-forge

WORKDIR /
RUN --mount=type=cache,target=/root/.cache/forge-repo \
  git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git && \
  cd stable-diffusion-webui-forge && \
  sed -i '/torch/d' requirements_versions.txt && \
  pip install -r requirements_versions.txt

RUN if [ -d "/opt/conda/lib/python3.10" ]; then \
      echo Python 3.10 detected; \
      sed -i 's/in_app_dir = .*/in_app_dir = True/g' /opt/conda/lib/python3.10/site-packages/gradio/routes.py  ;\
    elif [ -d "/opt/conda/lib/python3.11" ]; then \
      echo Python 3.11 detected; \
      sed -i 's/in_app_dir = .*/in_app_dir = True/g' /opt/conda/lib/python3.11/site-packages/gradio/routes.py ;\
    fi && \
  # mv ${ROOT}/style.css ${ROOT}/user.css && \
  # one of the ugliest hacks I ever wrote \
  # updated from 3.10.to 3.11
  git config --global --add safe.directory '*'



# drop permissions (if build targets non root)
USER $PUID:$PGID


COPY --from=download --chown=${PUID}:${PGID} /repositories/ ${ROOT}/repositories/
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate
RUN --mount=type=cache,target=/root/.cache/codeformer pip install -r ${ROOT}/repositories/CodeFormer/requirements.txt

# Clone and copy huggingface_guess module
#RUN git clone https://github.com/lllyasviel/huggingface_guess.git /tmp/huggingface_guess && \
#  cp -r /tmp/huggingface_guess/huggingface_guess ${ROOT}/huggingface_guess

# Ensure torchvision is correctly installed
RUN --mount=type=cache,target=/root/.cache/torch pip install torchvision==0.18.1

RUN --mount=type=cache,target=/root/.cache/repos \
  pip install pyngrok xformers==0.0.27 pytorch_lightning torchdiffeq torchsde \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@v2.20.0 
# there seems to be a memory leak (or maybe just memory not being freed fast enough) that is fixed by this version of malloc
# maybe move this up to the dependencies list.

ENV LD_PRELOAD=libtcmalloc.so

COPY . /docker

RUN chown -R "$PUID:$PGID" "${ROOT}"
RUN chown -R "$PUID:$PGID" /docker


WORKDIR ${ROOT}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u webui.py --listen --port 7860 ${CLI_ARGS}
