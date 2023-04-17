FROM python:3.8-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.13.0 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt install gcc libsndfile1 ffmpeg build-essential zip unzip git -y && apt-get clean

RUN --mount=type=cache,target=/root/.cache/pip \
  git config --global http.postBuffer 1048576000 && \
  git clone https://github.com/Sygil-Dev/sygil-webui.git stable-diffusion && \
  cd stable-diffusion && \
  git reset --hard 5291437085bddd16d752f811b6552419a2044d12 && \
  pip install -r requirements.txt


ARG BRANCH=master SHA=571fb897edd58b714bb385dfaa1ad59aecef8bc7
RUN --mount=type=cache,target=/root/.cache/pip \
  cd stable-diffusion && \
  git fetch && \
  git checkout ${BRANCH} && \
  git reset --hard ${SHA} && \
  pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip pip install -U 'transformers>=4.24'

# add info
COPY . /docker/
RUN python /docker/info.py /stable-diffusion/frontend/frontend.py && \
  chmod +x /docker/mount.sh /docker/run.sh && \
  # streamlit \
  sed -i -- 's/8501/7860/g' /stable-diffusion/.streamlit/config.toml

WORKDIR /stable-diffusion
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" STREAMLIT_SERVER_HEADLESS=true USE_STREAMLIT=0 CLI_ARGS=""
EXPOSE 7860

CMD /docker/mount.sh && /docker/run.sh
