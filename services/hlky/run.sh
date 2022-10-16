#!/bin/bash

set -Eeuo pipefail

echo "USE_STREAMLIT = ${USE_STREAMLIT}"
if [ "${USE_STREAMLIT}" == "1" ]; then
  python -u -m streamlit run scripts/webui_streamlit.py
else
  python3 -u scripts/webui.py --outdir /output --ckpt /data/StableDiffusion/model.ckpt ${CLI_ARGS}
fi
