#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/output"]="/output/comfy"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/models/checkpoints"]="/data/models/Stable-diffusion"
MOUNTS["${ROOT}/models/configs"]="/data/models/Stable-diffusion"
MOUNTS["${ROOT}/models/vae"]="/data/models/VAE"
MOUNTS["${ROOT}/models/loras"]="/data/models/Lora"
MOUNTS["${ROOT}/models/controlnet"]="/data/models/ControlNet"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/models/hypernetworks"
MOUNTS["${ROOT}/models/gligen"]="/data/models/GLIGEN"
MOUNTS["${ROOT}/models/clip"]="/data/models/CLIPEncoder"

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
