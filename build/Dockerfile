# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0


RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y
RUN git clone https://github.com/hlky/stable-diffusion.git && cd stable-diffusion && git reset --hard 554bd068e6f2f6bc55449a67fe017ddd77090f28
RUN conda env update --file stable-diffusion/environment.yaml --name base && conda clean -a -y


RUN git clone https://github.com/hlky/stable-diffusion-webui.git && cd stable-diffusion-webui && \
  git reset --hard b2dc4539d4171ab4fc78471a5bb9425d6a5d5445 && \
  cp -t /stable-diffusion/scripts/  txt2img.yaml webui.py webui.yaml webui_playground.py  && \
  cd / && rm -rf stable-diffusion-webui



ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""

WORKDIR /stable-diffusion

EXPOSE 7860
CMD ln -sf /models/model.ckpt /stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt && \
  ln -sf /models/GFPGANv1.3.pth   /stable-diffusion/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth && \
  ln -sf /models/RealESRGAN_x4plus.pth   /stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth && \
  # force facexlib cache
  mkdir -p /cache/weights/ && rm -rf /opt/conda/lib/python3.8/site-packages/facexlib/weights && \
  ln -sf  /cache/weights/ /opt/conda/lib/python3.8/site-packages/facexlib/ && \
  # run, -u to not buffer stdout / stderr
  python3 -u scripts/webui.py ${CLI_ARGS}
