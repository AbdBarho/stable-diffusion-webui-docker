#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

# cache
MOUNTS["/root/.cache"]=/data/.cache
# ui specific
MOUNTS["${PWD}/src/gfpgan/experiments/pretrained_models/GFPGANv1.4.pth"]=/data/GFPGAN/GFPGANv1.4.pth
MOUNTS["${PWD}/ldm/invoke/restoration/codeformer/weights"]=/data/Codeformer
MOUNTS["${PWD}/configs/models.yaml"]=/docker/models.yaml
# hacks
MOUNTS["/opt/conda/lib/python3.9/site-packages/facexlib/weights"]=/data/.cache
MOUNTS["/opt/conda/lib/python3.9/site-packages/realesrgan/weights"]=/data/RealESRGAN
MOUNTS["${PWD}/src/realesrgan/weights"]=/data/RealESRGAN
MOUNTS["${PWD}/gfpgan/weights"]=/data/.cache

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

if "${PRELOAD}" == "true"; then
  python3 -u scripts/preload_models.py --no-interactive
fi

exec "$@"
