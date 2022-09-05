# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download
RUN <<EOF
# who knows
git config --global http.postBuffer 1048576000
git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
rm -rf repositories/taming-transformers/data repositories/taming-transformers/assets
EOF

FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install git fonts-dejavu-core -y && apt-get clean

RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard 064965c4660f57f24e2d51a9854defaeabf8c0cf
pip install -U --prefer-binary --no-cache-dir -r requirements.txt
EOF

RUN <<EOF
pip install --prefer-binary -U --no-cache-dir diffusers numpy invisible-watermark git+https://github.com/crowsonkb/k-diffusion.git \
  git+https://github.com/TencentARC/GFPGAN.git markupsafe==2.0.1 opencv-python-headless
EOF


ENV ROOT=/workspace/stable-diffusion-webui \
  WORKDIR=/workspace/stable-diffusion-webui/repositories/stable-diffusion \
  TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""

COPY --from=download /git/ ${ROOT}


COPY . /docker

WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && python3 -u ../../webui.py --listen ${CLI_ARGS}
