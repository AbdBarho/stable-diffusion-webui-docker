import sys
from pathlib import Path

file = Path(sys.argv[1])
file.write_text(
  file.read_text()\
  .replace('GitHub site</a>', """
  GitHub site</a>, Deployed with <a href="https://github.com/AbdBarho/stable-diffusion-webui-docker/">stable-diffusion-webui-docker</a>
""", 1)
)
