#!/bin/bash

set -Eeuo pipefail

rm -rf /root/.cache
ln -sT /data/.cache /root/.cache

declare -A FOLDERS

# main
FOLDERS["/data/StableDiffusion"]="${ROOT}/models/Stable-diffusion"
FOLDERS["/data/Codeformer"]="${ROOT}/models/Codeformer"
FOLDERS["/data/GFPGAN"]="${ROOT}/models/GFPGAN"
FOLDERS["/data/ESRGAN"]="${ROOT}/models/ESRGAN"
FOLDERS["/data/BSRGAN"]="${ROOT}/models/BSRGAN"
FOLDERS["/data/RealESRGAN"]="${ROOT}/models/RealESRGAN"
FOLDERS["/data/SwinIR"]="${ROOT}/models/SwinIR"
FOLDERS["/data/LDSR"]="${ROOT}/models/LDSR"

# extra hacks
FOLDERS["/data/.cache"]="${ROOT}/repositories/CodeFormer/weights/facelib"

for from_path in "${!FOLDERS[@]}"; do
  set -Eeuo pipefail
  to_path="${FOLDERS[${from_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

# declare -A MODELS

# MODELS["${ROOT}/GFPGANv1.3.pth"]=GFPGANv1.3.pth
# MODELS["${WORKDIR}/repositories/latent-diffusion/experiments/pretrained_models/model.chkpt"]=LDSR.ckpt
# MODELS["${WORKDIR}/repositories/latent-diffusion/experiments/pretrained_models/project.yaml"]=LDSR.yaml

# MODELS_DIR=/cache/models

# for path in "${!MODELS[@]}"; do
#   name=${MODELS[$path]}
#   base=$(dirname "${path}")
#   from_path="${MODELS_DIR}/${name}"
#   if test -f "${from_path}"; then
#     mkdir -p "${base}" && ln -sf "${from_path}" "${path}" && echo "Mounted ${name}"
#   else
#     echo "Skipping ${name}"
#   fi
# done

# # force realesrgan cache
# rm -rf /opt/conda/lib/python3.8/site-packages/realesrgan/weights
# ln -s -T "${MODELS_DIR}" /opt/conda/lib/python3.8/site-packages/realesrgan/weights

# # force facexlib cache
# mkdir -p /cache/weights/ ${WORKDIR}/gfpgan/
# ln -sf /cache/weights/ ${WORKDIR}/gfpgan/
# # code former cache
# rm -rf ${ROOT}/repositories/CodeFormer/weights/CodeFormer ${ROOT}/repositories/CodeFormer/weights/facelib
# ln -sf -T /cache/weights ${ROOT}/repositories/CodeFormer/weights/CodeFormer
# ln -sf -T /cache/weights ${ROOT}/repositories/CodeFormer/weights/facelib
