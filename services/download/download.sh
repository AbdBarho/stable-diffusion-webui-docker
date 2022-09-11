#!/usr/bin/env bash

set -Eeuo pipefail

# [[ "$(sha256sum -b $file | head -c 64)" == "$sha" ]]

declare -A MODELS

MODELS['model.ckpt']='https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media'
MODELS['GFPGANv1.3.pth']='https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth'
MODELS['RealESRGAN_x4plus.pth']='https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth'
MODELS['RealESRGAN_x4plus_anime_6B.pth']='https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth'
MODELS['LDSR.yaml']='https://heibox.uni-heidelberg.de/f/31a76b13ea27482981b4/?dl=1'
MODELS['LDSR.ckpt']='https://heibox.uni-heidelberg.de/f/578df07c8fc04ffbadf3/?dl=1'

echo "Downloading..."

for file in "${!MODELS[@]}"; do
  url=${MODELS[$file]}
  full_path="/cache/models/$file"

  if [[ -f "$full_path" ]]; then
    echo "- $file exists"
    continue
  fi

  mkdir -p $(dirname $full_path)
  wget --tries=10 -c -O $full_path $url
done

echo "Checking SHAs..."

time parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"
