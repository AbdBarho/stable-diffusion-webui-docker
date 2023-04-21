#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS


mkdir -vp /data/config/comfy/

# cache
MOUNTS["/root/.cache"]=/data/.cache
# ui specific
MOUNTS["${ROOT}/models/checkpoints"]="/data/StableDiffusion"
MOUNTS["${ROOT}/models/controlnet"]="/data/ControlNet"
MOUNTS["${ROOT}/models/upscale_models/RealESRGAN"]="/data/RealESRGAN"
MOUNTS["${ROOT}/models/upscale_models/GFPGAN"]="/data/GFPGAN"
MOUNTS["${ROOT}/models/upscale_models/SwinIR"]="/data/SwinIR"
MOUNTS["${ROOT}/models/vae"]="/data/VAE"

# data
MOUNTS["${ROOT}/models/loras"]="/data/Lora"
MOUNTS["${ROOT}/models/embeddings"]="/data/embeddings"

# config
# TODO: I am not sure if this is final, maybe it should change in the future
MOUNTS["${ROOT}/models/clip"]="/data/.cache/comfy/clip"
MOUNTS["${ROOT}/models/clip_vision"]="/data/.cache/comfy/clip_vision"
MOUNTS["${ROOT}/models/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/models/style_models"]="/data/config/comfy/style_models"
MOUNTS["${ROOT}/models/t2i_adapter"]="/data/config/comfy/t2i_adapter"

# output
MOUNTS["${ROOT}/output"]="/output/comfy"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

exec "$@"
