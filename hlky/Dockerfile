# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean


RUN <<EOF
git clone https://github.com/sd-webui/stable-diffusion-webui.git stable-diffusion
cd stable-diffusion
git reset --hard 2b1ac8daf7ea82c6c56eabab7e80ec1c33106a98
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

# new dependency, should be added to the environment.yaml
RUN pip install -U --no-cache-dir pyperclip

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
ARG WEBUI_SHA=2b1ac8daf7ea82c6c56eabab7e80ec1c33106a98
RUN cd stable-diffusion && git pull && git reset --hard ${WEBUI_SHA} && \
  conda env update --file environment.yaml --name base && conda clean -a -y

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
RUN python /docker/info.py /stable-diffusion/frontend/frontend.py && chmod +x /docker/mount.sh

WORKDIR /stable-diffusion
ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && python3 -u scripts/webui.py --outdir /output --ckpt /models/model.ckpt --ldsr-dir /latent-diffusion ${CLI_ARGS}
