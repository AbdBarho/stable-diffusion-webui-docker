# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive

RUN conda install python=3.8.5 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync gcc -y && apt-get clean


RUN <<EOF
git config --global http.postBuffer 1048576000
git clone https://github.com/sd-webui/stable-diffusion-webui.git stable-diffusion
cd stable-diffusion
git reset --hard 1a9c053cb7b6832695771db2555c0adc9b41e95f
conda env update --file environment.yaml -n base
conda clean -a -y
EOF


ARG BRANCH=dev SHA=bd57d22f2e0ec7eed084bdf2a4c0dcc0ed745daf
RUN <<EOF
cd stable-diffusion
git fetch
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

# add info
COPY . /docker/
RUN <<EOF
python /docker/info.py /stable-diffusion/frontend/frontend.py
chmod +x /docker/mount.sh /docker/run.sh
# streamlit
sed -i -- 's/8501/7860/g' /stable-diffusion/.streamlit/config.toml
EOF

WORKDIR /stable-diffusion
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" STREAMLIT_SERVER_HEADLESS=true USE_STREAMLIT=0 CLI_ARGS=""
EXPOSE 7860

CMD /docker/mount.sh && /docker/run.sh
