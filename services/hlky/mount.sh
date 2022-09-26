#!/bin/bash

set -e

declare -A MODELS

ROOT=/stable-diffusion/src

MODELS["${ROOT}/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth"]=GFPGANv1.3.pth
MODELS["${ROOT}/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth"]=RealESRGAN_x4plus.pth
MODELS["${ROOT}/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus_anime_6B.pth"]=RealESRGAN_x4plus_anime_6B.pth
MODELS["${ROOT}/latent-diffusion/experiments/pretrained_models/model.ckpt"]=LDSR.ckpt
MODELS["${ROOT}/latent-diffusion/experiments/pretrained_models/project.yaml"]=LDSR.yaml

MODELS_DIR=/cache/models

for path in "${!MODELS[@]}"; do
  name=${MODELS[$path]}
  base=$(dirname "${path}")
  from_path="${MODELS_DIR}/${name}"
  if test -f "${from_path}"; then
    mkdir -p "${base}" && ln -sf "${from_path}" "${path}" && echo "Mounted ${name}"
  else
    echo "Skipping ${name}"
  fi
done

# force facexlib cache
mkdir -p /cache/weights/ /stable-diffusion/gfpgan/
ln -sf /cache/weights/ /stable-diffusion/gfpgan/

# streamlit config
ln -sf /docker/userconfig_streamlit.yaml /stable-diffusion/configs/webui/userconfig_streamlit.yaml
