# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1

# now it requires python3.9
RUN conda install python=3.9 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core -y && apt-get clean

RUN <<EOF
git clone https://github.com/invoke-ai/InvokeAI.git stable-diffusion
cd stable-diffusion
git reset --hard 986cc49d7a8441a70c709c04a55016a1c783f2ed
git config --global http.postBuffer 1048576000
# conda env update --file environment.yml -n base
conda clean -a -y
EOF


ARG BRANCH=development SHA=fdf9b1c40c243d6806e787877e42ae4c115790ee
RUN <<EOF
cd stable-diffusion
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yml -n base
conda clean -a -y
EOF

RUN pip uninstall opencv-python -y && pip install --prefer-binary --force-reinstall --no-cache-dir opencv-python-headless

COPY . /docker/
RUN <<EOF
python3 /docker/info.py /stable-diffusion/frontend/dist/index.html
chmod +x /docker/mount.sh
EOF


ENV PRELOAD=false CLI_ARGS=""
WORKDIR /stable-diffusion
EXPOSE 7860

CMD /docker/mount.sh && \
  python3 -u scripts/invoke.py --outdir /output --web --host 0.0.0.0 --port 7860 ${CLI_ARGS}
