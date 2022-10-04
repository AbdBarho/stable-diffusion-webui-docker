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
git reset --hard 7623a5734740025d79b710f3744bff9276e1467b
conda env update --file environment.yaml -n base
conda clean -a -y
EOF


# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
# ARG BRANCH=master  SHA=d0bb60a139d60e6c2b9be4e18e0e29a86aa5af59
ARG BRANCH=dev SHA=1e7bdfe3f38a6dd37fc230f440ea1b0db0937240
RUN <<EOF
cd stable-diffusion
git fetch
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

RUN pip install -U --no-cache-dir pyperclip

# add info
COPY . /docker/
RUN python /docker/info.py /stable-diffusion/frontend/frontend.py && chmod +x /docker/mount.sh

WORKDIR /stable-diffusion
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && \
  python3 -u scripts/webui.py --outdir /output --ckpt /data/StableDiffusion/model.ckpt ${CLI_ARGS}
# sed -i -- 's/8501/7860/g' .streamlit/config.toml && STREAMLIT_SERVER_HEADLESS=true python -u -m streamlit run scripts/webui_streamlit.py  --theme.base dark
