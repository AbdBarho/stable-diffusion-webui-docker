# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download
RUN <<EOF
# because taming-transformers is huge
git config --global http.postBuffer 1048576000
git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer
git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion
git clone https://github.com/salesforce/BLIP.git repositories/BLIP
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
rm -rf repositories/taming-transformers/data repositories/taming-transformers/assets
EOF


FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean


RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard 13eec4f3d4081fdc43883c5ef02e471a2b6c7212
conda env update --file environment-wsl2.yaml -n base
conda clean -a -y
pip install --prefer-binary --no-cache-dir -r requirements.txt
EOF

ENV ROOT=/stable-diffusion-webui \
  WORKDIR=/stable-diffusion-webui/repositories/stable-diffusion

COPY --from=download /git/ ${ROOT}
RUN pip install --prefer-binary --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
ARG SHA=85b97cc49c4766cb47306e71e552871a0791ea29
RUN <<EOF
cd stable-diffusion-webui
git pull --rebase
git reset --hard ${SHA}
pip install --prefer-binary --no-cache-dir -r requirements.txt
EOF

RUN pip install --prefer-binary -U --no-cache-dir opencv-python-headless
#gfpgan==1.3.5

ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""

COPY . /docker
RUN chmod +x /docker/mount.sh && python3 /docker/info.py ${ROOT}/modules/ui.py


WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && python3 -u ../../webui.py --listen --port 7860 --hide-ui-dir-config ${CLI_ARGS}
