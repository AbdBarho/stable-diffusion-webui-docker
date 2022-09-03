import sys
from pathlib import Path

file = Path(sys.argv[1])
file.write_text(
  file.read_text()\
  .replace('<p>For help and advanced usage guides,', """
  <p>
    Created using <a href="https://github.com/AbdBarho/stable-diffusion-webui-docker">stable-diffusion-webui-docker</a>.
  </p>
  <p>For help and advanced usage guides,
""", 1)
)
