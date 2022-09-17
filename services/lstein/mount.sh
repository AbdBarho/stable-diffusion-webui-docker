#!/bin/bash

set -eu

ROOT=/stable-diffusion

mkdir -p "${ROOT}/models/ldm/stable-diffusion-v1/"
ln -sf /cache/models/model.ckpt "${ROOT}/models/ldm/stable-diffusion-v1/model.ckpt"

if test -f /cache/models/GFPGANv1.3.pth; then
  base="${ROOT}/src/gfpgan/experiments/pretrained_models/"
  mkdir -p "${base}"
  ln -sf /cache/models/GFPGANv1.3.pth "${base}/GFPGANv1.3.pth"
  echo "Mounted GFPGANv1.3.pth"
fi

# facexlib
FACEX_WEIGHTS=/opt/conda/lib/python3.8/site-packages/facexlib/weights

rm -rf "${FACEX_WEIGHTS}"
mkdir -p /cache/weights
ln -sf -T /cache/weights "${FACEX_WEIGHTS}"

if "${PRELOAD}" == "true"; then
  python3 -u scripts/preload_models.py
fi
