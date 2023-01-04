#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

# cache
MOUNTS["/root/.cache"]=/data/.cache/

# ui specific
MOUNTS["${ROOT}/models/codeformer"]=/data/Codeformer/

MOUNTS["${ROOT}/models/gfpgan/GFPGANv1.4.pth"]=/data/GFPGAN/GFPGANv1.4.pth
MOUNTS["${ROOT}/models/gfpgan/weights"]=/data/.cache/

MOUNTS["${ROOT}/models/realesrgan"]=/data/RealESRGAN/

MOUNTS["${ROOT}/models/bert-base-uncased"]=/data/.cache/huggingface/transformers/
MOUNTS["${ROOT}/models/openai/clip-vit-large-patch14"]=/data/.cache/huggingface/transformers/
MOUNTS["${ROOT}/models/CompVis/stable-diffusion-safety-checker"]=/data/.cache/huggingface/transformers/

MOUNTS["${ROOT}/embeddings"]=/data/embeddings/

# hacks
MOUNTS["${ROOT}/models/clipseg"]=/data/.cache/invoke/clipseg/

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
  python3 -u scripts/preload_models.py --skip-sd-weights --root ${ROOT} --config_file /docker/models.yaml
fi

exec "$@"
