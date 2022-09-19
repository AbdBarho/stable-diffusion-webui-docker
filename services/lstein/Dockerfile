# syntax=docker/dockerfile:1

FROM continuumio/miniconda3:4.12.0

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive

# now it requires python3.9
RUN conda install python=3.9 && conda clean -a -y
RUN conda install pytorch==1.11.0 torchvision==0.12.0 cudatoolkit=11.3 -c pytorch && conda clean -a -y

RUN apt-get update && apt install fonts-dejavu-core rsync gcc -y && apt-get clean


RUN <<EOF
git clone https://github.com/lstein/stable-diffusion.git
cd stable-diffusion
git reset --hard e994073b5bdfa3c77313681c5944be1544eb65b6
sed -i -- 's/python=3.8.5/python=3.9/g' environment.yaml
conda env update --file environment.yaml -n base
conda clean -a -y
EOF


ARG BRANCH=development SHA=50d607ffea3734072a80e38b09ba0c3758af5d40
# ARG BRANCH=main SHA=89da371f4841f7e05da5a1672459d700c3920784
RUN <<EOF
cd stable-diffusion
git fetch
git reset --hard
git checkout ${BRANCH}
git reset --hard ${SHA}
conda env update --file environment.yaml -n base
conda clean -a -y
EOF

RUN pip uninstall opencv-python -y && pip install --prefer-binary --force-reinstall --no-cache-dir opencv-python-headless transformers==4.22

COPY . /docker/
RUN <<EOF
python3 /docker/info.py /stable-diffusion/static/dream_web/index.html
chmod +x /docker/mount.sh
sed -i -- 's/outputs\//\/output/g' /stable-diffusion/backend/server.py
EOF


ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch PRELOAD=false CLI_ARGS=""
WORKDIR /stable-diffusion
EXPOSE 7860

CMD /docker/mount.sh && \
  python3 -u scripts/dream.py --outdir /output --web --host 0.0.0.0 --port 7860 ${CLI_ARGS}
  #python3 -u backend/server.py
