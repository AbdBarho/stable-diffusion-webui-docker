#!/bin/bash

set -Eeuo pipefail

# TODO: move all mkdir -p ?
mkdir -p /data/config/auto/scripts/
# mount scripts individually
find "${ROOT}/scripts/" -maxdepth 1 -type l -delete
cp -vrfTs /data/config/auto/scripts/ "${ROOT}/scripts/"

cp -n /docker/config.json /data/config/auto/config.json
jq '. * input' /data/config/auto/config.json /docker/config.json | sponge /data/config/auto/config.json

if [ ! -f /data/config/auto/ui-config.json ]; then
  echo '{}' >/data/config/auto/ui-config.json
fi

if [ ! -f /data/config/auto/styles.csv ]; then
  touch /data/config/auto/styles.csv
fi

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"

# main
MOUNTS["${ROOT}/models/Stable-diffusion"]="/data/StableDiffusion"
MOUNTS["${ROOT}/models/VAE"]="/data/VAE"
MOUNTS["${ROOT}/models/Codeformer"]="/data/Codeformer"
MOUNTS["${ROOT}/models/GFPGAN"]="/data/GFPGAN"
MOUNTS["${ROOT}/models/ESRGAN"]="/data/ESRGAN"
MOUNTS["${ROOT}/models/BSRGAN"]="/data/BSRGAN"
MOUNTS["${ROOT}/models/RealESRGAN"]="/data/RealESRGAN"
MOUNTS["${ROOT}/models/SwinIR"]="/data/SwinIR"
MOUNTS["${ROOT}/models/ScuNET"]="/data/ScuNET"
MOUNTS["${ROOT}/models/LDSR"]="/data/LDSR"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/Hypernetworks"
MOUNTS["${ROOT}/models/torch_deepdanbooru"]="/data/Deepdanbooru"
MOUNTS["${ROOT}/models/BLIP"]="/data/BLIP"
MOUNTS["${ROOT}/models/midas"]="/data/MiDaS"
MOUNTS["${ROOT}/models/Lora"]="/data/Lora"
MOUNTS["${ROOT}/models/LyCORIS"]="/data/LyCORIS"
MOUNTS["${ROOT}/models/ControlNet"]="/data/ControlNet"
MOUNTS["${ROOT}/models/openpose"]="/data/openpose"
MOUNTS["${ROOT}/models/ModelScope"]="/data/ModelScope"

MOUNTS["${ROOT}/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/config.json"]="/data/config/auto/config.json"
MOUNTS["${ROOT}/ui-config.json"]="/data/config/auto/ui-config.json"
MOUNTS["${ROOT}/styles.csv"]="/data/config/auto/styles.csv"
MOUNTS["${ROOT}/extensions"]="/data/config/auto/extensions"

# extra hacks
MOUNTS["${ROOT}/repositories/CodeFormer/weights/facelib"]="/data/.cache"

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

if [ -f "/data/config/auto/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/auto/startup.sh
  popd
fi

exec "$@"
