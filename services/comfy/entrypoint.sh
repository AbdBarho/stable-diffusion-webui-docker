#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/output"]="/output/comfy"

# mount various locations for comfyui to keep custom nodes and models downloaded with comfyui manager
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"

MOUNTS["${ROOT}/models/checkpoints"]="/data/models/checkpoints"
#MOUNTS["${ROOT}/models/configs"]="/data/models/configs"
MOUNTS["${ROOT}/models/embeddings"]="/data/models/embeddings"
MOUNTS["${ROOT}/models/gligen"]="/data/models/gligen"
MOUNTS["${ROOT}/models/mmdets"]="/data/models/mmdets"
MOUNTS["${ROOT}/models/style_models"]="/data/models/style_models"
#MOUNTS["${ROOT}/models/vae"]="/data/models/vae"
#MOUNTS["${ROOT}/models/clip"]="/data/models/clip"
#MOUNTS["${ROOT}/models/controlnet"]="/data/models/controlnet"
MOUNTS["${ROOT}/models/facedetection"]="/data/models/facedetection"

MOUNTS["${ROOT}/models/hypernetworks"]="/data/models/hypernetworks"


#MOUNTS["${ROOT}/models/onnx"]="/data/models/onnx"
#MOUNTS["${ROOT}/models/unet"]="/data/models/unet"
MOUNTS["${ROOT}/models/vae_approx"]="/data/models/vae-approx"
#MOUNTS["${ROOT}/models/clip_vision"]="/data/models/clip_vision"
#MOUNTS["${ROOT}/models/diffusers"]="/data/models/diffusers"
MOUNTS["${ROOT}/models/facerestore_models"]="/data/models/facerestore_models"
MOUNTS["${ROOT}/models/loras"]="/data/models/lora"
MOUNTS["${ROOT}/models/sams"]="/data/models/sams"
MOUNTS["${ROOT}/models/upscale_models"]="/data/models/upscale_models"


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

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

exec "$@"
