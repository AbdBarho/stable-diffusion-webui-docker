# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync -y && apt-get clean


RUN <<EOF
git clone https://github.com/lstein/stable-diffusion.git
cd stable-diffusion
git reset --hard 751283a2de81bee4bb571fbabe4adb19f1d85b97
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""

WORKDIR /stable-diffusion

EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD mkdir -p /stable-diffusion/models/ldm/stable-diffusion-v1/ && \
  ln -sf /models/model.ckpt /stable-diffusion/models/ldm/stable-diffusion-v1/model.ckpt && \
  python3 -u scripts/dream.py --outdir /output --web --host 0.0.0.0 --port 7860 ${CLI_ARGS}
