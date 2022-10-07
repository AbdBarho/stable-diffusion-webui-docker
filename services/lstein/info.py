import sys
from pathlib import Path

file = Path(sys.argv[1])
file.write_text(
  file.read_text()\
  .replace('  <div id="root"></div>', """
    <div id="root"></div>
    <div>
      Deployed with <a href="https://github.com/AbdBarho/stable-diffusion-webui-docker/">stable-diffusion-webui-docker</a>
    </div>
""", 1)
)
