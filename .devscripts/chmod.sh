#!/bin/bash

set -Eeuo pipefail

find services -name "*.sh" -exec git update-index --chmod=+x {} \;
find .devscripts -name "*.sh" -exec git update-index --chmod=+x {} \;
