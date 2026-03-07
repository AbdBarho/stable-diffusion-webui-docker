#!/bin/bash
# Get custom nodes requirements and merge latest versions
REQ_PATH="data/config/comfy/custom_nodes"
BUILD_PATH=$(dirname "$0")

mkdir -p ${BUILD_PATH}/reqs
for f in ${REQ_PATH}/*/requirements.txt; do \
  node=$(basename $(dirname "$f")); \
  cp "$f" ${BUILD_PATH}/reqs/${node}-requirements.txt; \
done
find ${BUILD_PATH}/reqs -maxdepth 1 -name "*requirements.txt" -exec sh -c 'cat "$1"; echo' _ {} \; \
  | grep -v '^#' \
  | grep -v '^git' \
  | grep -Ev 'platform_system|platform_machine|sys_platform|google|onnx|opencv-python-headless\[ffmpeg\]' \
  | sed 's/==.*//' \
  | awk '{print tolower($0)}' \
  | sed 's/[[:space:]]//g' \
  | sort -u \
  | awk '
      {
          line = $0;
          if (line ~ /^[[:space:]]*$/) { next }
          if (line ~ /git\+/ || line ~ /\[.*\]/) {
              print "Z_" line, "0", line
              next
          }
          split(line, a, "[<>=]")
          package = a[1]
          version = a[2]
          gsub(/[[:space:]]+/, "", package)
          gsub(/_/, "-", package)
          if (version == "") {
              version = "0"
          }
          print package, version, line
      }
  ' \
  | sort -k1,1 -V -k2,2 \
  | awk '
      {
          if (prev_package != $1) {
              if (NR > 1) {
                  print prev_line
              }
              prev_package = $1
          }
          prev_line = $3
      }
      END {
          print prev_line
      }
  ' \
  > ${BUILD_PATH}/merged-requirements.txt
