# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean


RUN <<EOF
git clone https://github.com/hlky/stable-diffusion.git
cd stable-diffusion
git reset --hard c84748aa6802c2f934687883a79bde745d2a58a6
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

# new dependency, should be added to the environment.yaml
RUN pip install -U --no-cache-dir pyperclip

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
RUN cd stable-diffusion && git pull && git reset --hard bb765f1897c968495ffe12a06b421d97b56d5ae1 && \
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
git reset --hard 6d61fc03f15273a457950f2cdc10dddf53ba6809 &&
# hacks all the way down
mv ldm ldm_latent &&
sed -i -- 's/from ldm/from ldm_latent/g' *.py
# dont forget to update the yaml!!
EOF


# add info
COPY . /docker/
RUN python /docker/info.py /stable-diffusion/frontend/frontend.py

WORKDIR /stable-diffusion
ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && python3 -u scripts/webui.py --outdir /output --ckpt /models/model.ckpt --ldsr-dir /latent-diffusion ${CLI_ARGS}
