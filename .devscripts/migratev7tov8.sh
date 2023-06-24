#!/bin/bash

set -Eeuo pipefail

echo "Renaming..."

# compatible with default auto-names
mv -v ./data/StableDiffusion ./data/Stable-diffusion
mv -v ./data/Deepdanbooru ./data/torch_deepdanbooru

# casing problem on windows
mv -v ./data/Hypernetworks ./data/hypernetworks1
mv -v ./data/hypernetworks1 ./data/hypernetworks

mv -v ./data/MiDaS ./data/midas1
mv -v ./data/midas1 ./data/midas


echo "Moving folders..."

mkdir -pv ./final

mv -v ./data/config ./final/config
mv -v ./data/.cache ./final/.cache
mv -v ./data/embeddings ./final/embeddings
mv -v ./data ./final/models

mv -v ./final ./data
