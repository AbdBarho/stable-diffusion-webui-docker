# syntax=docker/dockerfile:1

FROM python:3.8-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.0 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt install gcc libsndfile1 ffmpeg build-essential zip unzip git -y && apt-get clean

RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git config --global http.postBuffer 1048576000
git clone https://github.com/Sygil-Dev/sygil-webui.git stable-diffusion
cd stable-diffusion
git reset --hard 5291437085bddd16d752f811b6552419a2044d12
pip install -r requirements.txt
EOF


ARG BRANCH=dev SHA=e48482823bb73697a6f1e39b3a7e47fe2ba1d697
RUN --mount=type=cache,target=/root/.cache/pip <<EOF
cd stable-diffusion
git fetch
git checkout ${BRANCH}
git reset --hard ${SHA}
pip install -r requirements.txt
EOF

RUN --mount=type=cache,target=/root/.cache/pip pip install transformers==4.24.0

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
