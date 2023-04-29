#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS


mkdir -vp /data/config/comfy/

# cache
MOUNTS["/root/.cache"]="/data/.cache"

# ui specific
MOUNTS["${ROOT}/models/checkpoints"]="/data/StableDiffusion"
MOUNTS["${ROOT}/models/controlnet"]="/data/ControlNet"
MOUNTS["${ROOT}/models/vae"]="/data/VAE"
MOUNTS["${ROOT}/models/loras"]="/data/Lora"
MOUNTS["${ROOT}/models/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/Hypernetworks"

MOUNTS["${ROOT}/models/upscale_models/RealESRGAN"]="/data/RealESRGAN"
MOUNTS["${ROOT}/models/upscale_models/GFPGAN"]="/data/GFPGAN"
MOUNTS["${ROOT}/models/upscale_models/SwinIR"]="/data/SwinIR"

# config
# TODO: I am not sure if this is final, maybe it should change in the future
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/models/configs"]="/data/config/comfy/configs"

MOUNTS["${ROOT}/models/style_models"]="/data/config/comfy/models/style_models"
MOUNTS["${ROOT}/models/t2i_adapter"]="/data/config/comfy/models/t2i_adapter"
MOUNTS["${ROOT}/models/clip"]="/data/config/comfy/models/clip"
MOUNTS["${ROOT}/models/clip_vision"]="/data/config/comfy/models/clip_vision"
MOUNTS["${ROOT}/models/gligen"]="/data/config/comfy/models/gligen"
MOUNTS["${ROOT}/models/diffusers"]="/data/config/comfy/models/diffusers"

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
