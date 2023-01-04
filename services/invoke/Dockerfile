# syntax=docker/dockerfile:1

FROM python:3.10-slim
SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1


RUN --mount=type=cache,target=/root/.cache/pip \
  pip install torch==1.12.0+cu116 --extra-index-url https://download.pytorch.org/whl/cu116

RUN apt-get update && apt-get install git -y && apt-get clean

RUN git clone https://github.com/invoke-ai/InvokeAI.git /stable-diffusion

WORKDIR /stable-diffusion

RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git reset --hard 5c31feb3a1096d437c94b6e1c3224eb7a7224a85
git config --global http.postBuffer 1048576000
pip install -r binary_installer/py3.10-linux-x86_64-cuda-reqs.txt
EOF


# patch match:
# https://github.com/invoke-ai/InvokeAI/blob/main/docs/installation/INSTALL_PATCHMATCH.md
RUN <<EOF
apt-get update
# apt-get install build-essential python3-opencv libopencv-dev -y
apt-get install make g++ libopencv-dev -y
apt-get clean
cd /usr/lib/x86_64-linux-gnu/pkgconfig/
ln -sf opencv4.pc opencv.pc
EOF

ARG BRANCH=main SHA=21bf512056eb7bc883174a4203011105fc1b8b50
RUN --mount=type=cache,target=/root/.cache/pip <<EOF
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
pip install -r binary_installer/py3.10-linux-x86_64-cuda-reqs.txt
EOF

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -U --force-reinstall opencv-python-headless huggingface_hub && \
  python3 -c "from patchmatch import patch_match"


RUN touch invokeai.init
COPY . /docker/


ENV ROOT=/stable-diffusion PYTHONPATH="${PYTHONPATH}:${ROOT}" PRELOAD=false CLI_ARGS=""
EXPOSE 7860

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python3 -u scripts/invoke.py --web --host 0.0.0.0 --port 7860 --config /docker/models.yaml --root_dir ${ROOT} --outdir /output/invoke ${CLI_ARGS}
