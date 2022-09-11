#!/bin/bash

set -Eeuo pipefail

find . -name "*.sh" -exec git update-index --chmod=+x {} \;
