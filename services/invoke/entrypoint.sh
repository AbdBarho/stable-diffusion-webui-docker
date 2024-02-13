#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

mkdir -p ${CONFIG_DIR} ${ROOT}/configs/stable-diffusion/

# cache
MOUNTS["/root/.cache"]=/data/.cache/

# this is really just a hack to avoid migrations
rm -rf ${HF_HOME}/diffusers

# ui specific
MOUNTS["${ROOT}/models/codeformer"]=/data/models/Codeformer/
MOUNTS["${ROOT}/models/gfpgan/GFPGANv1.4.pth"]=/data/models/GFPGAN/GFPGANv1.4.pth
MOUNTS["${ROOT}/models/gfpgan/weights"]=/data/models/GFPGAN/
MOUNTS["${ROOT}/models/realesrgan"]=/data/models/RealESRGAN/

MOUNTS["${ROOT}/models/ldm"]=/data/.cache/invoke/ldm/

# hacks

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

if "${PRELOAD}" == "true"; then
  set -Eeuo pipefail
  invokeai-configure --root ${ROOT} --yes
  cp ${ROOT}/configs/models.yaml ${CONFIG_DIR}/models.yaml
fi

exec "$@"
