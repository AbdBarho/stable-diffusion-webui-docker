# syntax=docker/dockerfile:1

FROM python:3.10-slim

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1


RUN pip install torch==1.13.0 torchvision --extra-index-url https://download.pytorch.org/whl/cu117

RUN apt-get update && apt-get install git -y && apt-get clean

RUN git clone https://github.com/invoke-ai/InvokeAI.git /stable-diffusion

WORKDIR /stable-diffusion

RUN <<EOF
git reset --hard 2b7e3abe57963d199f1d825ddef87ae154c81045
git config --global http.postBuffer 1048576000
ln -sf environments-and-requirements/requirements-lin-cuda.txt requirements.txt
pip install -r requirements.txt
EOF


ARG BRANCH=development SHA=a9aa4e45aa6f5d5a2aa385349131d8733dd380fa
RUN <<EOF
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
pip install -r requirements.txt
EOF

RUN pip install --force-reinstall opencv-python-headless==4.5.5.64

COPY . /docker/
RUN <<EOF
python3 /docker/info.py /stable-diffusion/frontend/dist/index.html
touch ~/.invokeai
EOF


ENV ROOT=/stable-diffusion PRELOAD=false CLI_ARGS=""
EXPOSE 7860


ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python3 -u scripts/invoke.py --web --host 0.0.0.0 --port 7860 --config /docker/models.yaml --root_dir . --outdir /output ${CLI_ARGS}
