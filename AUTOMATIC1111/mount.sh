#!/bin/bash

declare -A MODELS

MODELS["${WORKDIR}/models/ldm/stable-diffusion-v1/model.ckpt"]=model.ckpt
MODELS["${ROOT}/GFPGANv1.3.pth"]=GFPGANv1.3.pth

for path in "${!MODELS[@]}"; do
  name=${MODELS[$path]}
  base=$(dirname "${path}")
  from_path="/models/${name}"
  if test -f "${from_path}"; then
    mkdir -p "${base}" && ln -sf "${from_path}" "${path}" && echo "Mounted ${name}"
  else
    echo "Skipping ${name}"
  fi
done

# force realesrgan cache
rm -rf /opt/conda/lib/python3.7/site-packages/realesrgan/weights
ln -s -T /models /opt/conda/lib/python3.7/site-packages/realesrgan/weights

# force facexlib cache
mkdir -p /cache/weights/ ${WORKDIR}/gfpgan/
ln -sf /cache/weights/ ${WORKDIR}/gfpgan/
# code former cache
rm -rf ${ROOT}/repositories/CodeFormer/weights/CodeFormer ${ROOT}/repositories/CodeFormer/weights/facelib
ln -sf -T /cache/weights ${ROOT}/repositories/CodeFormer/weights/CodeFormer
ln -sf -T /cache/weights ${ROOT}/repositories/CodeFormer/weights/facelib

# mount config
ln -sf /docker/config.json ${WORKDIR}/config.json
