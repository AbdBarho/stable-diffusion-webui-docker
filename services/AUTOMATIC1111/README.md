# WebUI for AUTOMATIC1111

The WebUI of [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) as docker container!

## Setup

Clone this repo, download the `model.ckpt` and `GFPGANv1.3.pth` and put into the `models` folder as mentioned in [the main README](../README.md), then run

```
cd AUTOMATIC1111
docker compose up --build
```

You can change the cli parameters in `AUTOMATIC1111/docker-compose.yml`. The full list of cil parameters can be found [here](https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/modules/shared.py)
