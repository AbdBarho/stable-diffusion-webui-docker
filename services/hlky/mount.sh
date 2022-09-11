#!/bin/bash

set -e

declare -A MODELS
MODELS["/stable-diffusion/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth"]=GFPGANv1.3.pth
MODELS["/stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth"]=RealESRGAN_x4plus.pth
MODELS["/stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus_anime_6B.pth"]=RealESRGAN_x4plus_anime_6B.pth
MODELS["/latent-diffusion/experiments/pretrained_models/model.ckpt"]=LDSR.ckpt
# MODELS["/latent-diffusion/experiments/pretrained_models/project.yaml"]=LDSR.yaml

for path in "${!MODELS[@]}"; do
  name=${MODELS[$path]}
  base=$(dirname "${path}")
  from_path="/models/${name}"
  if test -f "${from_path}"; then
    mkdir -p "${base}" && ln -sf "${from_path}" "${path}" && echo "Mounted ${name}"
  else
    echo "Skipping ${name}"
  fi
done

# hack for latent-diffusion
if test -f /models/LDSR.yaml; then
  sed 's/ldm\./ldm_latent\./g' /models/LDSR.yaml >/latent-diffusion/experiments/pretrained_models/project.yaml
fi

# force facexlib cache
mkdir -p /cache/weights/ /stable-diffusion/gfpgan/
ln -sf /cache/weights/ /stable-diffusion/gfpgan/
