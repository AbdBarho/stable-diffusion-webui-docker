#!/bin/bash

set -Eeuo pipefail

# TODO: move all mkdir -p ?
mkdir -p /data/config/forge/scripts/
# mount scripts individually

echo $ROOT
ls -lha $ROOT

find "${ROOT}/scripts/" -maxdepth 1 -type l -delete
cp -vrfTs /data/config/forge/scripts/ "${ROOT}/scripts/"

# Set up config file
python /docker/config.py /data/config/forge/config.json

if [ ! -f /data/config/forge/ui-config.json ]; then
  echo '{}' >/data/config/forge/ui-config.json
fi

if [ ! -f /data/config/forge/styles.csv ]; then
  touch /data/config/forge/styles.csv
fi

# copy models from original models folder
mkdir -p /data/models/VAE-approx/ /data/models/karlo/

rsync -a --info=NAME ${ROOT}/models/VAE-approx/ /data/models/VAE-approx/
rsync -a --info=NAME ${ROOT}/models/karlo/ /data/models/karlo/

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/models"]="/data/models"

MOUNTS["${ROOT}/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/config.json"]="/data/config/forge/config.json"
MOUNTS["${ROOT}/ui-config.json"]="/data/config/forge/ui-config.json"
MOUNTS["${ROOT}/styles.csv"]="/data/config/forge/styles.csv"
MOUNTS["${ROOT}/extensions"]="/data/config/forge/extensions"
MOUNTS["${ROOT}/config_states"]="/data/config/forge/config_states"

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

echo "Installing extension dependencies (if any)"

# because we build our container as root:
chown -R root ~/.cache/
chmod 766 ~/.cache/

shopt -s nullglob
# For install.py, please refer to https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Developing-extensions#installpy
list=(./extensions/*/install.py)
for installscript in "${list[@]}"; do
  EXTNAME=$(echo $installscript | cut -d '/' -f 3)
  # Skip installing dependencies if extension is disabled in config
  if $(jq -e ".disabled_extensions|any(. == \"$EXTNAME\")" config.json); then
    echo "Skipping disabled extension ($EXTNAME)"
    continue
  fi
  PYTHONPATH=${ROOT} python "$installscript"
done

if [ -f "/data/config/forge/startup.sh" ]; then
  pushd ${ROOT}
  echo "Running startup script"
  . /data/config/forge/startup.sh
  popd
fi

exec "$@"
