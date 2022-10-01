#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

ROOT=/stable-diffusion/src

# cache
MOUNTS["/root/.cache"]=/data/.cache
# ui specific
MOUNTS["${ROOT}/gfpgan/experiments/pretrained_models/GFPGANv1.3.pth"]=/data/GFPGAN/GFPGANv1.4.pth
MOUNTS["${ROOT}/realesrgan/experiments/pretrained_models"]=/data/RealESRGAN
MOUNTS["${ROOT}/latent-diffusion/experiments/pretrained_models"]=/data/LDSR
# hacks
MOUNTS["/stable-diffusion/gfpgan/weights"]=/data/.cache

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

# streamlit config
ln -sf /docker/userconfig_streamlit.yaml /stable-diffusion/configs/webui/userconfig_streamlit.yaml
