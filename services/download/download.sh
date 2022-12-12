#!/usr/bin/env bash

set -Eeuo pipefail

# TODO: maybe just use the .gitignore file to create all of these
mkdir -vp /data/.cache /data/StableDiffusion /data/Codeformer /data/GFPGAN /data/ESRGAN /data/BSRGAN /data/RealESRGAN /data/SwinIR /data/LDSR /data/ScuNET /data/embeddings /data/VAE /data/Deepdanbooru /data/MiDaS

echo "Downloading, this might take a while..."

aria2c -x 10 --disable-ipv6 --input-file /docker/links.txt --dir /data --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"

cat <<EOF
By using this software, you agree to the following licenses:
https://github.com/CompVis/stable-diffusion/blob/main/LICENSE
https://github.com/AbdBarho/stable-diffusion-webui-docker/blob/master/LICENSE
https://github.com/sd-webui/stable-diffusion-webui/blob/master/LICENSE
https://github.com/invoke-ai/InvokeAI/blob/main/LICENSE
https://github.com/cszn/BSRGAN/blob/main/LICENSE
https://github.com/sczhou/CodeFormer/blob/master/LICENSE
https://github.com/TencentARC/GFPGAN/blob/master/LICENSE
https://github.com/xinntao/Real-ESRGAN/blob/master/LICENSE
https://github.com/xinntao/ESRGAN/blob/master/LICENSE
https://github.com/cszn/SCUNet/blob/main/LICENSE
EOF
