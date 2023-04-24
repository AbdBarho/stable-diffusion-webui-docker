#!/bin/bash

set -Eeuo pipefail

# TODO: move all mkdir -p ?
mkdir -p /data/config/auto/scripts/
# mount scripts individually
find "${ROOT}/scripts/" -maxdepth 1 -type l -delete
cp -vrfTs /data/config/auto/scripts/ "${ROOT}/scripts/"

# config.json for auto
cp -n /docker/config.json /data/config/auto/config.json
## Step 1: Copy default config to user config if missing
cp -n /docker/config.json /data/config/auto/config.json
## Step 2: Put the default config and user config into vars
cfg_json_default=$(cat /docker/config.json)
cfg_json_user=$(cat /data/config/auto/config.json)
## Step 3: delete invalid entries from user.json
cfg_json_user=$(echo $cfg_json_user | jq '
  . as $original
    | reduce (to_entries[] | select((.key | startswith("outdir_"))
        and (.value | test("^\/output(\\.)?(\/\\.?[\\w\\-\\_]+)+\/?")|not)))
        as $item
        ($original; del(.[$item.key]))
')
## Step 4: Merge and save config
echo $cfg_json_default $cfg_json_user | jq '. * input' | sponge /data/config/auto/config.json

if [ ! -f /data/config/auto/ui-config.json ]; then
  echo '{}' >/data/config/auto/ui-config.json
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
MOUNTS["${ROOT}/models/ControlNet"]="/data/ControlNet"
MOUNTS["${ROOT}/models/openpose"]="/data/openpose"

MOUNTS["${ROOT}/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/config.json"]="/data/config/auto/config.json"
MOUNTS["${ROOT}/ui-config.json"]="/data/config/auto/ui-config.json"
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
