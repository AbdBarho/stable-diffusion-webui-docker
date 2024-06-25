FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git && apt-get clean

ENV ROOT=/stable-diffusion
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout master && \
  git reset --hard 276f8fce9f5a80b500947fb5745a4dde9e84622d && \
  pip install -r requirements.txt

# Checkpoint
RUN wget -c https://huggingface.co/jzli/DreamShaper-8/resolve/main/dreamshaper_8.safetensors?download=true -P ./models/checkpoints/
# VAE
RUN wget -c https://huggingface.co/stabilityai/sdxl-vae/blob/main/sdxl_vae.safetensors -P ./models/vae/
# Custom nodes
RUN cd custom_nodes && git clone https://github.com/Yanick112/ComfyUI-ToSVG.git
# ComfyUI Manager
RUN cd custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

WORKDIR ${ROOT}
COPY . /docker/
RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml ${ROOT}

ENV NVIDIA_VISIBLE_DEVICES=all PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
