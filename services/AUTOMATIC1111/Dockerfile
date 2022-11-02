# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download

SHELL ["/bin/sh", "-ceuxo", "pipefail"]

RUN <<EOF
cat <<'EOE' > /clone.sh
mkdir -p repositories/"$1" && cd repositories/"$1" && git init && git remote add origin "$2" && git fetch origin "$3" --depth=1 && git reset --hard "$3" && rm -rf .git
EOE
EOF

RUN . /clone.sh taming-transformers https://github.com/CompVis/taming-transformers.git 24268930bf1dce879235a7fddd0b2355b84d7ea6 \
  && rm -rf data assets **/*.ipynb

RUN . /clone.sh stable-diffusion https://github.com/CompVis/stable-diffusion.git 69ae4b35e0a0f6ee1af8bb9a5d0016ccb27e36dc \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git f4e99857772fc3a126ba886aadf795a332774878
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2486589f24165c8e3b303f84e9dbbea318df83e8


FROM alpine:3 as xformers
RUN apk add aria2
RUN aria2c --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/2.1.0/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl'

FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1

RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113

RUN apt-get update && apt install fonts-dejavu-core rsync git jq moreutils -y && apt-get clean


RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard d885a4a57b72152745ca76192ef1bdda29e6461d
pip install -r requirements_versions.txt
EOF


COPY --from=xformers /wheel.whl xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl
RUN pip install xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl && rm xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl


ENV ROOT=/stable-diffusion-webui


COPY --from=download /git/ ${ROOT}
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/data/* ${ROOT}/interrogate
RUN pip install --prefer-binary --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt


# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step

ARG SHA=cd5eafaf03a25d2b0e35154666947b9489078af9
RUN <<EOF
cd stable-diffusion-webui
git fetch
git reset --hard ${SHA}
pip install -r requirements_versions.txt
EOF

RUN pip install opencv-python-headless \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  pyngrok


COPY . /docker

RUN chmod +x /docker/entrypoint.sh && python3 /docker/info.py ${ROOT}/modules/ui.py

WORKDIR ${ROOT}/repositories/stable-diffusion
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
# run, -u to not buffer stdout / stderr
CMD python3 -u ../../webui.py --listen --port 7860 --ckpt-dir ${ROOT}/models/Stable-diffusion --theme dark ${CLI_ARGS}
