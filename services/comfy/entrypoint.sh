#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/output"]="/output/comfy"

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

if [ "$(ls -A /stable-diffusion/custom_nodes)" ]; then
  chmod 777 -R "/stable-diffusion/custom_nodes/"
  apt-get install build-essential -y
  for dir in "/stable-diffusion/custom_nodes/*"; do
    if [ -e "$dir/requirements.txt" ]; then
      echo $dir
      cd $dir
      pip install -r requirements.txt
    fi
  done
fi

exec "$@"
