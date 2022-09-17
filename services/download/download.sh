#!/usr/bin/env bash

set -Eeuo pipefail

mkdir -p /cache/torch /cache/transformers /cache/weights /cache/models /cache/custom-models

echo "Downloading, this might take a while..."

aria2c --input-file /docker/links.txt --dir /cache/models --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"
