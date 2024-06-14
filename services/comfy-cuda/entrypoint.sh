#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/my_workflows"]="/data/config/comfy/my_workflows"
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

if [ -z "$(ls -A /data/config/comfy/custom_nodes/ComfyUI_UltimateSDUpscale)" ]; then
  git -C /data/config/comfy/custom_nodes clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive
fi

if [ -z "$(ls -A /data/config/comfy/custom_nodes/comfyui-workspace-manager)" ]; then
  git -C /data/config/comfy/custom_nodes clone https://github.com/11cafe/comfyui-workspace-manager.git
fi

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

exec "$@"
