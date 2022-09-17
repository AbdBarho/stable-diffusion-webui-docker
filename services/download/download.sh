#!/usr/bin/env bash

set -Eeuo pipefail

echo "Downloading, this might take a while..."

aria2c --input-file /docker/links.txt --dir /cache/models --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"
