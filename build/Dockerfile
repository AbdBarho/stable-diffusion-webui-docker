# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0


RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y
RUN git clone https://github.com/hlky/stable-diffusion.git && cd stable-diffusion && git reset --hard 554bd068e6f2f6bc55449a67fe017ddd77090f28
RUN conda env update --file stable-diffusion/environment.yaml --name base && conda clean -a -y

# fonts for generating the grid
RUN apt-get update && apt install fonts-dejavu-core && apt-get clean

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
RUN cd stable-diffusion && git pull && git reset --hard ac31d943ce0c99b7dd4df7e6cb1c14f2e275ca96 && \
  conda env update --file environment.yaml --name base && conda clean -a -y

# download dev UI version, update the sha below in case you want some other version
RUN git clone https://github.com/hlky/stable-diffusion-webui.git && cd stable-diffusion-webui && \
  git reset --hard 244f945c40b8dec3fd1faf8824b99abeb3bc4b97 && \
  cp -t /stable-diffusion/scripts/ txt2img.yaml webui.py webui.yaml webui_playground.py && \
  cd / && rm -rf stable-diffusion-webui


# For testing different versions:
# RUN git clone https://github.com/AbdBarho/stable-diffusion-webui.git && cd stable-diffusion-webui && \
#   git checkout respect-cli-params &&\
#   cp -t /stable-diffusion/scripts/ txt2img.yaml webui.py webui.yaml webui_playground.py && \
#   cd / && rm -rf stable-diffusion-webui


# add info
COPY info.py /info.py
RUN  python /info.py /stable-diffusion/scripts/webui.py

WORKDIR /stable-diffusion
ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""
EXPOSE 7860
CMD \
  ln -sf /models/GFPGANv1.3.pth   /stable-diffusion/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth && \
  ln -sf /models/RealESRGAN_x4plus.pth   /stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth && \
  # force facexlib cache
  mkdir -p /cache/weights/ && rm -rf /opt/conda/lib/python3.8/site-packages/facexlib/weights && \
  ln -sf  /cache/weights/ /opt/conda/lib/python3.8/site-packages/facexlib/ && \
  # run, -u to not buffer stdout / stderr
  python3 -u scripts/webui.py --outdir /output --save-metadata --ckpt /models/model.ckpt ${CLI_ARGS}
