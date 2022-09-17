# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync gcc -y && apt-get clean


RUN <<EOF
git clone https://github.com/lstein/stable-diffusion.git
cd stable-diffusion
git reset --hard 751283a2de81bee4bb571fbabe4adb19f1d85b97
conda env update --file environment.yaml -n base
conda clean -a -y
EOF


ARG BRANCH=development SHA=45af30f3a4c98b50c755717831c5fff75a3a8b43
# ARG BRANCH=main SHA=89da371f4841f7e05da5a1672459d700c3920784
RUN <<EOF
cd stable-diffusion
git fetch
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

RUN pip uninstall opencv-python -y && pip install --prefer-binary --upgrade --force-reinstall --no-cache-dir opencv-python-headless

COPY . /docker/
RUN python3 /docker/info.py /stable-diffusion/static/dream_web/index.html && chmod +x /docker/mount.sh

ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch PRELOAD=false CLI_ARGS=""
WORKDIR /stable-diffusion
EXPOSE 7860

CMD /docker/mount.sh && python3 -u scripts/dream.py --outdir /output --web --host 0.0.0.0 --port 7860 ${CLI_ARGS}
