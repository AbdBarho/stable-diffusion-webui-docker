#!/usr/bin/env python3

"""Checks and sets default values for config.json before starting the container."""

import json
import re
import os.path
import sys

DEFAULT_FILEPATH = '/data/config/auto/config.json'

DEFAULT_OUTDIRS = {
  "outdir_samples": "",
  "outdir_txt2img_samples": "/output/txt2img",
  "outdir_img2img_samples": "/output/img2img",
  "outdir_extras_samples": "/output/extras",
  "outdir_grids": "",
  "outdir_txt2img_grids": "/output/txt2img-grids",
  "outdir_img2img_grids": "/output/img2img-grids",
  "outdir_save": "/output/saved",
  "outdir_init_images": "/output/init-images",
}
RE_VALID_OUTDIR = re.compile(r"(^/output(/\.?[\w\-\_]+)+/?$)|(^\s?$)")

DEFAULT_OTHER = {
  "font": "DejaVuSans.ttf",
}

def dict_to_json_file(target_file: str, data: dict):
  """Write dictionary to specified json file"""

  with open(target_file, 'w') as f:
    json.dump(data, f)

def json_file_to_dict(config_file: str) -> dict|None:
   """Load json file into a dictionary. Return None if file does not exist."""

   if os.path.isfile(config_file):
    with open(config_file, 'r') as f:
      return json.load(f)
   else:
      return None

def replace_if_invalid(value: str, replacement: str, pattern: str|re.Pattern[str]) -> str:
  """Returns original value if valid, fallback value if invalid"""

  if re.match(pattern, value):
    return value
  else:
    return replacement

def check_and_replace_config(config_file: str, target_file: str = None):
  """Checks given file for invalid values. Replaces those with fallback values (default: overwrites file)."""

  # Get current user config, or empty if file does not exists
  data = json_file_to_dict(config_file) or {}

  # Check and fix output directories
  for k, def_val in DEFAULT_OUTDIRS.items():
    if k not in data:
      data[k] = def_val
    else:
      data[k] = replace_if_invalid(value=data[k], replacement=def_val, pattern=RE_VALID_OUTDIR)

  # Check and fix other default settings
  for k, def_val in DEFAULT_OTHER.items():
    if k not in data:
      data[k] = def_val

  # Write results to file
  dict_to_json_file(target_file or config_file, data)

if __name__ == '__main__':
  if len(sys.argv) > 1:
    check_and_replace_config(*sys.argv[1:])
  else:
    check_and_replace_config(DEFAULT_FILEPATH)

