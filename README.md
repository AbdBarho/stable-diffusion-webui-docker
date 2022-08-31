# Stable Diffusion WebUI Docker

Run Stable Diffusion on your machine with a nice UI without any hassle!

This repository provides the [WebUI](https://github.com/hlky/stable-diffusion-webui) as docker for easy setup and deployment. Please note that this repo delivers all cutting-edge unstable changes from the WebUI, so expect some bugs.

## Setup

make sure you have docker installed and up to date. Download this repo and run:

```
docker compose build
```

you can let it build in the background while you download the different models

- [Stable Diffusion v1.4 (4GB)](https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media), rename to `model.ckpt`
- (Optional) [GFPGANv1.3.pth (333MB)](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth) to improve generated faces.
- (Optional) [RealESRGAN_x4plus.pth (64MB)](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth) and [RealESRGAN_x4plus_anime_6B.pth (18MB)](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth) for super-sampling.

Put all of the downloaded files in the `models` folder, it should look something like this:

```
models/
├── GFPGANv1.3.pth
├── RealESRGAN_x4plus.pth
├── RealESRGAN_x4plus_anime_6B.pth
└── model.ckpt
```

## Run

After the build is done, you can run the app with:

```
docker compose up --build
```

Will start the app on http://localhost:7860/

Note: the first start will take sometime as some other models will be downloaded, these will be cached in the `cache` folder, so next runs are faster.

## Config

in the `docker-compose.yml` you can change the `CLI_ARGS` variable contains all of the variables that will be passed to [the web ui](https://github.com/hlky/stable-diffusion/blob/fa977b3d6f9d0b264035c949fd70415476f00036/scripts/webui.py).

By default: `--gfpgan-gpu 0 --esrgan-cpu --optimized-turbo` are given, which allow you to use this model on a 6GB GPU.
NOTE: GFPGAN does not work on the CPU [More info here](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/4)

# Disclaimer

The authors of this project are not responsible for any content generated using this interface.

This license of this software forbids you from sharing any content that violates any laws, produce any harm to a person, disseminate any personal information that would be meant for harm, spread misinformation and target vulnerable groups. For the full list of restrictions please read [the license](./LICENSE).

# Thanks

Special thanks to everyone behind these awesome projects, without them, none of this would have been possible:

- [hlky/stable-diffusion-webui](https://github.com/hlky/stable-diffusion-webui)
- [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [CompVis/stable-diffusion](https://github.com/CompVis/stable-diffusion)
