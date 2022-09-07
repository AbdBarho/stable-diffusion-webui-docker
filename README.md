# Stable Diffusion WebUI Docker

Run Stable Diffusion on your machine with a nice UI without any hassle!

This repository provides the [WebUI](https://github.com/hlky/stable-diffusion-webui) as a docker image for easy setup and deployment.

Now with experimental support for 2 other forks:

- [AUTOMATIC1111](./AUTOMATIC1111/) (Stable, very few bugs!)
- [lstein](./lstein/)

NOTE: big update coming up!

## Features

- Interactive UI with many features, and more on the way!
- Support for 6GB GPU cards.
- GFPGAN for face reconstruction, RealESRGAN for super-sampling.
- Experimental:
  - Latent Diffusion Super Resolution
  - GoBig
  - GoLatent
- many more!

## Setup

Make sure you have an **up to date** version of docker installed. Download this repo and run:

```
docker compose build
```

you can let it build in the background while you download the different models

- [Stable Diffusion v1.4 (4GB)](https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media), rename to `model.ckpt`
- (Optional) [GFPGANv1.3.pth (333MB)](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth).
- (Optional) [RealESRGAN_x4plus.pth (64MB)](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth) and [RealESRGAN_x4plus_anime_6B.pth (18MB)](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth).
- (Optional) [LDSR (2GB)](https://heibox.uni-heidelberg.de/f/578df07c8fc04ffbadf3/?dl=1) and [its configuration](https://heibox.uni-heidelberg.de/f/31a76b13ea27482981b4/?dl=1), rename to `LDSR.ckpt` and `LDSR.yaml` respectively.
<!-- - (Optional) [RealESRGAN_x2plus.pth (64MB)](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth)
- TODO: (I still need to find the RealESRGAN_x2plus_6b.pth) -->

Put all of the downloaded files in the `models` folder, it should look something like this:

```
models/
├── model.ckpt
├── GFPGANv1.3.pth
├── RealESRGAN_x4plus.pth
├── RealESRGAN_x4plus_anime_6B.pth
├── LDSR.ckpt
└── LDSR.yaml
```

## Run

After the build is done, you can run the app with:

```
docker compose up --build
```

Will start the app on http://localhost:7860/

Note: the first start will take sometime as some other models will be downloaded, these will be cached in the `cache` folder, so next runs are faster.

### FAQ

You can find fixes to common issues [in the wiki page.](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/FAQ)

## Config

in the `docker-compose.yml` you can change the `CLI_ARGS` variable, which contains the arguments that will be passed to the WebUI. By default: `--extra-models-cpu --optimized-turbo` are given, which allow you to use this model on a 6GB GPU. However, some features might not be available in the mode. [You can find the full list of arguments here.](https://github.com/hlky/stable-diffusion-webui/blob/2b1ac8daf7ea82c6c56eabab7e80ec1c33106a98/scripts/webui.py)

You can set the `WEBUI_SHA` to [any SHA from the main repo](https://github.com/hlky/stable-diffusion/commits/main), this will build the container against that commit. Use at your own risk.

# Disclaimer

The authors of this project are not responsible for any content generated using this interface.

This license of this software forbids you from sharing any content that violates any laws, produce any harm to a person, disseminate any personal information that would be meant for harm, spread misinformation and target vulnerable groups. For the full list of restrictions please read [the license](./LICENSE).

# Thanks

Special thanks to everyone behind these awesome projects, without them, none of this would have been possible:

- [hlky/stable-diffusion-webui](https://github.com/hlky/stable-diffusion-webui)
- [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [lstein/stable-diffusion](https://github.com/lstein/stable-diffusion)
- [CompVis/stable-diffusion](https://github.com/CompVis/stable-diffusion)
- [hlky/sd-enable-textual-inversion](https://github.com/hlky/sd-enable-textual-inversion)
- [devilismyfriend/latent-diffusion](https://github.com/devilismyfriend/latent-diffusion)
