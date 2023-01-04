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

RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git 47b6b607fdd31875c9279cd2f4f16b92e4ea958e \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git 5b3af030dd83e0297272d861c19477735d0317ec
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2486589f24165c8e3b303f84e9dbbea318df83e8


FROM alpine:3 as xformers
RUN apk add aria2
RUN aria2c -x 5 --dir / --out wheel.whl 'https://github.com/AbdBarho/stable-diffusion-webui-docker/releases/download/4.0.0/xformers-0.0.16rc393-cp310-cp310-manylinux2014_x86_64.whl'

FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN PIP_NO_CACHE_DIR=1 pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116

RUN apt-get update && apt install fonts-dejavu-core rsync git jq moreutils -y && apt-get clean


RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard 4af3ca5393151d61363c30eef4965e694eeac15e
pip install -r requirements_versions.txt
EOF

RUN --mount=type=cache,target=/root/.cache/pip  \
  --mount=type=bind,from=xformers,source=/wheel.whl,target=/xformers-0.0.15-cp310-cp310-linux_x86_64.whl \
  pip install triton /xformers-0.0.15-cp310-cp310-linux_x86_64.whl

ENV ROOT=/stable-diffusion-webui


COPY --from=download /git/ ${ROOT}
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/data/* ${ROOT}/interrogate
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -r ${ROOT}/repositories/CodeFormer/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install opencv-python-headless \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@bb6e834e9c70d9c27d0dc3ecedeebeaeb1ffad6b \
  pyngrok

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step

ARG SHA=81490780949fffed77493b4bd741e96ec737fe27
RUN --mount=type=cache,target=/root/.cache/pip <<EOF
cd stable-diffusion-webui
git fetch
git reset --hard ${SHA}
pip install -r requirements_versions.txt
EOF

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -U opencv-python-headless transformers>=4.24

COPY . /docker

RUN <<EOF
python3 /docker/info.py ${ROOT}/modules/ui.py
mv ${ROOT}/style.css ${ROOT}/user.css
EOF

WORKDIR ${ROOT}
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python3 -u webui.py --listen --port 7860 ${CLI_ARGS}
