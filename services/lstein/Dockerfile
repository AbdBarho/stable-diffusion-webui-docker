# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive PIP_EXISTS_ACTION=w  PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1

# now it requires python3.9
RUN conda install python=3.9 && conda clean -a -y
RUN conda install cudatoolkit=11.6 -c conda-forge && conda clean -a -y
RUN conda install pytorch==1.12.1 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core -y && apt-get clean

RUN <<EOF
git clone https://github.com/invoke-ai/InvokeAI.git stable-diffusion
cd stable-diffusion
git reset --hard 6b89adfa7ebd4591ed91a76ecf152e3517cda385
git config --global http.postBuffer 1048576000
conda env update --file environment.yml -n base
conda clean -a -y
EOF


ARG BRANCH=main SHA=6b89adfa7ebd4591ed91a76ecf152e3517cda385
RUN <<EOF
cd stable-diffusion
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yml -n base
conda clean -a -y
EOF

RUN pip uninstall opencv-python -y && pip install --force-reinstall opencv-python-headless==4.5.5.64

COPY . /docker/
RUN <<EOF
python3 /docker/info.py /stable-diffusion/frontend/dist/index.html
EOF


ENV PRELOAD=false CLI_ARGS=""
WORKDIR /stable-diffusion
EXPOSE 7860


ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python3 -u scripts/invoke.py --outdir /output --web --host 0.0.0.0 --port 7860 ${CLI_ARGS}
