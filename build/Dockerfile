# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y
RUN git clone https://github.com/hlky/stable-diffusion.git && cd stable-diffusion && git reset --hard ff8c2d0b709f1e4180fb19fa5c27ec28c414cedd
RUN conda env update --file stable-diffusion/environment.yaml --name base && conda clean -a -y

# fonts for generating the grid
RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
RUN cd stable-diffusion && git pull && git reset --hard e51657753737f98f8586701b4b7562b846db9d44 && \
  conda env update --file environment.yaml --name base && conda clean -a -y

# download dev UI version, update the sha below in case you want some other version
# RUN <<EOF
# git clone https://github.com/hlky/stable-diffusion-webui.git
# cd stable-diffusion-webui
# # map to this file: https://github.com/hlky/stable-diffusion-webui/blob/master/.github/sync.yml
# git reset --hard 49e6178fd82ca736f9bbc621c6b12487c300e493
# cp -t /stable-diffusion/scripts/ webui.py relauncher.py txt2img.yaml
# cp -t /stable-diffusion/configs/webui webui.yaml
# cp -t /stable-diffusion/frontend/ frontend/*
# cd / && rm -rf stable-diffusion-webui
# EOF

# Textual inversion
RUN <<EOF
git clone https://github.com/hlky/sd-enable-textual-inversion.git &&
cd /sd-enable-textual-inversion && git reset --hard 08f9b5046552d17cf7327b30a98410222741b070 &&
rsync -a /sd-enable-textual-inversion/ /stable-diffusion/ &&
rm -rf /sd-enable-textual-inversion
EOF

# Latent diffusion
RUN <<EOF
git clone https://github.com/devilismyfriend/latent-diffusion &&
cd /latent-diffusion &&
git reset --hard b3896adb4784e9fc4ec600d91aa2cdaa6fe48285
EOF

# add info
COPY . /docker/
RUN python /docker/info.py /stable-diffusion/frontend/frontend.py

WORKDIR /stable-diffusion
ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /bin/bash -c /docker/mount.sh && python3 -u scripts/webui.py --outdir /output --ckpt /models/model.ckpt --ldsr-dir /latent-diffusion --save-metadata ${CLI_ARGS}
