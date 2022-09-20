#!/usr/bin/env bash

set -Eeuo pipefail

mkdir -p /cache/torch /cache/transformers /cache/weights /cache/models /cache/custom-models

cat <<EOF
By using this software, you agree to the following licenses:
https://github.com/CompVis/stable-diffusion/blob/main/LICENSE
https://github.com/TencentARC/GFPGAN/blob/master/LICENSE
https://github.com/xinntao/Real-ESRGAN/blob/master/LICENSE
EOF

echo "Downloading, this might take a while..."

aria2c --input-file /docker/links.txt --dir /cache/models --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"
