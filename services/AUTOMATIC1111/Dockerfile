# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

RUN git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard 69ae4b35e0a0f6ee1af8bb9a5d0016ccb27e36dc

RUN git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard c5b4593074ba6214284d6acd5f1719b6c5d739af
RUN git clone https://github.com/salesforce/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard 48211a1594f1321b00f14c9f7a5b4813144b2fb9

RUN <<EOF
# because taming-transformers is huge
git config --global http.postBuffer 1048576000
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
cd repositories/taming-transformers
git reset --hard 24268930bf1dce879235a7fddd0b2355b84d7ea6
rm -rf data assets
EOF

RUN git clone https://github.com/crowsonkb/k-diffusion.git repositories/k-diffusion && cd repositories/k-diffusion && git reset --hard f4e99857772fc3a126ba886aadf795a332774878

RUN git clone https://github.com/pharmapsychotic/clip-interrogator repositories/clip-interrogator && cd repositories/clip-interrogator && git reset --hard 2486589f24165c8e3b303f84e9dbbea318df83e8

FROM alpine:3 as xformers
RUN apk add aria2
RUN aria2c --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/2.1.0/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl'

FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1

RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113

RUN apt-get update && apt install fonts-dejavu-core rsync git -y && apt-get clean


RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard 1eb588cbf19924333b88beaa1ac0041904966640
pip install -r requirements_versions.txt
EOF

ENV ROOT=/stable-diffusion-webui \
  WORKDIR=/stable-diffusion-webui/repositories/stable-diffusion


COPY --from=download /git/ ${ROOT}
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/data/* ${ROOT}/interrogate
RUN pip install --prefer-binary --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt

# TODO: move to top
RUN apt-get install jq moreutils -y


# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step

ARG SHA=f49c08ea566385db339c6628f65c3a121033f67c
RUN <<EOF
cd stable-diffusion-webui
git pull --rebase
git reset --hard ${SHA}
pip install -r requirements_versions.txt
EOF

RUN pip install opencv-python-headless \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  pyngrok

COPY --from=xformers /wheel.whl xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl
RUN pip install xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl

COPY . /docker

RUN <<EOF
chmod +x /docker/mount.sh && python3 /docker/info.py ${ROOT}/modules/ui.py
EOF

ENV CLI_ARGS=""
WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && \
  python3 -u ../../webui.py --listen --port 7860 --ckpt-dir ${ROOT}/models/Stable-diffusion --theme dark ${CLI_ARGS}
