# syntax=docker/dockerfile:1

FROM alpine/git:2.36.2 as download
RUN <<EOF
# who knows
git config --global http.postBuffer 1048576000
git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer
git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion
git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
rm -rf repositories/taming-transformers/data repositories/taming-transformers/assets
EOF

FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install git fonts-dejavu-core -y && apt-get clean

RUN <<EOF
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
git reset --hard db6db585eb9ee48e7315e28603e18531dbc87067
pip install -U --prefer-binary --no-cache-dir -r requirements.txt
EOF

ENV ROOT=/workspace/stable-diffusion-webui \
  WORKDIR=/workspace/stable-diffusion-webui/repositories/stable-diffusion

COPY --from=download /git/ ${ROOT}
RUN pip install --prefer-binary -U --no-cache-dir -r ${ROOT}/repositories/CodeFormer/requirements.txt

# Note: don't update the sha of previous versions because the install will take forever
# instead, update the repo state in a later step
ARG SHA=17a7477c7282b0ff16fa1232e5922c0a645e4459
RUN <<EOF
cd stable-diffusion-webui
git pull
git reset --hard ${SHA}
pip install --prefer-binary --no-cache-dir -r requirements.txt
EOF

RUN pip install --prefer-binary -U --no-cache-dir opencv-python-headless markupsafe==2.0.1

ENV TRANSFORMERS_CACHE=/cache/transformers TORCH_HOME=/cache/torch CLI_ARGS=""

COPY . /docker
RUN chmod +x /docker/mount.sh && python3 /docker/info.py ${ROOT}/modules/ui.py

WORKDIR ${WORKDIR}
EXPOSE 7860
# run, -u to not buffer stdout / stderr
CMD /docker/mount.sh && python3 -u ../../webui.py --listen --port 7860 ${CLI_ARGS}
