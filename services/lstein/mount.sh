#!/bin/bash

set -eu

ROOT=/stable-diffusion

mkdir -p "${ROOT}/models/ldm/stable-diffusion-v1/"
ln -sf /cache/models/model.ckpt "${ROOT}/models/ldm/stable-diffusion-v1/model.ckpt"

base="${ROOT}/src/gfpgan/experiments/pretrained_models/"
mkdir -p "${base}"
# TODO: "real" GFPGANv1.4.pth
ln -sf /cache/models/GFPGANv1.3.pth "${base}/GFPGANv1.4.pth"
echo "Mounted GFPGANv1.3.pth"

# facexlib
FACEX_WEIGHTS=/opt/conda/lib/python3.9/site-packages/facexlib/weights

rm -rf "${FACEX_WEIGHTS}"
mkdir -p /cache/weights
ln -sf -T /cache/weights "${FACEX_WEIGHTS}"

REALESRGAN_WEIGHTS=/opt/conda/lib/python3.9/site-packages/realesrgan/weights
rm -rf "${REALESRGAN_WEIGHTS}"
ln -sf -T /cache/weights "${REALESRGAN_WEIGHTS}"

if "${PRELOAD}" == "true"; then
  python3 -u scripts/preload_models.py
fi
