#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

# cache
MOUNTS["/root/.cache"]=/data/.cache/

# this is really a hack to avoid migrations
rm -rf ${HF_HOME}/diffusers

# ui specific
MOUNTS["${ROOT}/models/codeformer"]=/data/Codeformer/
MOUNTS["${ROOT}/models/gfpgan/GFPGANv1.4.pth"]=/data/GFPGAN/GFPGANv1.4.pth
MOUNTS["${ROOT}/models/gfpgan/weights"]=/data/GFPGAN/
MOUNTS["${ROOT}/models/realesrgan"]=/data/RealESRGAN/

MOUNTS["${ROOT}/models/bert-base-uncased"]=/data/.cache/huggingface/transformers/
MOUNTS["${ROOT}/models/openai/clip-vit-large-patch14"]=/data/.cache/huggingface/transformers/
MOUNTS["${ROOT}/models/CompVis/stable-diffusion-safety-checker"]=/data/.cache/huggingface/transformers/
MOUNTS["${ROOT}/models/ldm"]=/data/.cache/invoke/ldm/

MOUNTS["${ROOT}/embeddings"]=/data/embeddings/

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
fi

sed -i 's|chunksize=4096|chunksize=16777216|' ${ROOT}/invokeai/backend/model_management/model_manager.py

exec "$@"
