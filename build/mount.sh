#!/bin/bash

set -e

declare -A MODELS
MODELS["/stable-diffusion/src/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth"]=GFPGANv1.3.pth
MODELS["/stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus.pth"]=RealESRGAN_x4plus.pth
MODELS["/stable-diffusion/src/realesrgan/experiments/pretrained_models/RealESRGAN_x4plus_anime_6B.pth"]=RealESRGAN_x4plus_anime_6B.pth
MODELS["/latent-diffusion/experiments/pretrained_models/model.ckpt"]=LDSR.ckpt
MODELS["/latent-diffusion/experiments/pretrained_models/project.yaml"]=LDSR.yaml

for path in "${!MODELS[@]}"; do
  name=${MODELS[$path]}
  base=$(dirname "${path}")
  test -f "/models/${name}" && mkdir -p "${base}" && ln -sf "/models/${name}" "${path}" && echo "Mounted ${name}"
done

# force facexlib cache
mkdir -p /cache/weights/
rm -rf /stable-diffusion/src/facexlib/facexlib/weights
ln -sf /cache/weights/ /stable-diffusion/src/facexlib/facexlib/
