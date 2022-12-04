#!/bin/bash

set -Eeuo pipefail

echo "Moving everything in output to output/old..."
mv output old
mkdir output
mv old/.gitignore output
mv old output
