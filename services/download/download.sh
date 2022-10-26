#!/usr/bin/env bash

set -Eeuo pipefail

mkdir -p /data/.cache /data/StableDiffusion /data/Codeformer /data/GFPGAN /data/ESRGAN /data/BSRGAN /data/RealESRGAN /data/SwinIR /data/LDSR /data/ScuNET /data/embeddings

echo "Downloading, this might take a while..."

aria2c --disable-ipv6 --input-file /docker/links.txt --dir /data --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"

# aria2c already does hash check
# cc6cb27103417325ff94f52b7a5d2dde45a7515b25c255d8e396c90014281516  /data/StableDiffusion/v1-5-pruned-emaonly.ckpt
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
