#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

ROOT=/stable-diffusion

sed -i 's/this\.allow_searchbox = true;/this.allow_searchbox = false;/' /stable-diffusion/web/lib/litegraph.core.js

# cache
MOUNTS["/root/.cache"]=/data/.cache
# ui specific
MOUNTS["${ROOT}/models/checkpoints"]="/data/StableDiffusion"
MOUNTS["${ROOT}/models/clip"]="/data/comfy/clip"
MOUNTS["${ROOT}/models/clip_vision"]="/data/comfy/clip_vision"
MOUNTS["${ROOT}/models/controlnet"]="/data/config/auto/extensions/sd-webui-controlnet/models"
MOUNTS["${ROOT}/models/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/models/loras"]="/data/Lora"
MOUNTS["${ROOT}/models/style_models"]="/data/comfy/style_models"
MOUNTS["${ROOT}/models/t2i_adapter"]="/data/comfy/t2i_adapter"
MOUNTS["${ROOT}/models/upscale_models/RealESRGAN"]="/data/RealESRGAN"
MOUNTS["${ROOT}/models/upscale_models/SwinIR"]="/data/SwinIR"
MOUNTS["${ROOT}/models/upscale_models/GFPGAN"]="/data/GFPGAN"
MOUNTS["${ROOT}/models/vae"]="/data/VAE"

MOUNTS["${ROOT}/output"]="/output"

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
