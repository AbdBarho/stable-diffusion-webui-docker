# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download


RUN git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && cd repositories/stable-diffusion && git reset --hard 69ae4b35e0a0f6ee1af8bb9a5d0016ccb27e36dc

RUN git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git reset --hard c5b4593074ba6214284d6acd5f1719b6c5d739af
RUN git clone https://github.com/salesforce/BLIP.git repositories/BLIP && cd repositories/BLIP && git reset --hard 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN git clone https://github.com/Hafiidz/latent-diffusion.git repositories/latent-diffusion && cd repositories/latent-diffusion && git reset --hard abf33e7002d59d9085081bce93ec798dcabd49af

RUN <<EOF
# because taming-transformers is huge
git config --global http.postBuffer 1048576000
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
git reset --hard 24268930bf1dce879235a7fddd0b2355b84d7ea6
rm -rf repositories/taming-transformers/data repositories/taming-transformers/assets
EOF

RUN git clone https://github.com/crowsonkb/k-diffusion.git repositories/k-diffusion && cd repositories/k-diffusion && git reset --hard 9e3002b7cd64df7870e08527b7664eb2f2f5f3f5


FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean


RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard 1eb588cbf19924333b88beaa1ac0041904966640
pip install --prefer-binary --no-cache-dir -r requirements_versions.txt
EOF

ENV ROOT=/stable-diffusion-webui \
  WORKDIR=/stable-diffusion-webui/repositories/stable-diffusion


COPY --from=download /git/ ${ROOT}
RUN pip install --prefer-binary --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step

ARG SHA=1eb588cbf19924333b88beaa1ac0041904966640
RUN <<EOF
cd stable-diffusion-webui
git pull --rebase
git reset --hard ${SHA}
pip install --prefer-binary --no-cache-dir -r requirements_versions.txt
pip install --prefer-binary --no-cache-dir -r requirements.txt
EOF

RUN pip install --prefer-binary --no-cache-dir opencv-python-headless \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1



COPY . /docker
RUN <<EOF
chmod +x /docker/mount.sh && python3 /docker/info.py ${ROOT}/modules/ui.py
EOF

ENV CLI_ARGS=""
WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && \
  python3 -u ../../webui.py --listen --port 7860 --hide-ui-dir-config --ckpt-dir ${ROOT}/models/Stable-diffusion ${CLI_ARGS}
#  --gfpgan-models-path /data/GFPGAN --codeformer-models-path /data/Codeformer --esrgan-models-path /data/ESRGAN --bsrgan-models-path /data/BSRGAN --realesrgan-models-path /data/RealESRGAN --swinir-models-path /data/SwinIR --ldsr-models-path /data/LDSR
