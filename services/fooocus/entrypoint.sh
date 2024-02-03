#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/fooocus/wildcards

declare -A MOUNTS

MOUNTS["${ROOT}/outputs"]="/output/fooocus"

# ui specific mounts
MOUNTS["${ROOT}/models/checkpoints"]=/data/models/Stable-diffusion/
MOUNTS["${ROOT}/models/loras"]=/data/models/Lora/
MOUNTS["${ROOT}/models/embeddings"]=/data/models/embeddings/
MOUNTS["${ROOT}/models/vae_approx"]=/data/models/VAE/
MOUNTS["${ROOT}/models/upscale_models"]=/data/models/upscale_models/
MOUNTS["${ROOT}/wildcards"]=/data/config/fooocus/wildcards

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  # ends with slash, make it!
  if [[ "$from_path" == */ ]]; then
    mkdir -vp "$from_path"
  fi

  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

exec "$@"
