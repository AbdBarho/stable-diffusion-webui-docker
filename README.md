# Stable Diffusion WebUI Docker

Run Stable Diffusion on your machine with a nice UI without any hassle!

This repository provides multiple UIs for you to play around with stable diffusion:

## Quick Start

- Install [Taskfile](https://taskfile.dev/installation?ref=AbdBarho-stable-diffusion-webui-docker)
    - Quick Snippet:
        - Linux: `sudo snap install task --classic`
        - MacOS: `HOMEBREW_NO_AUTO_UPDATE=1 brew install go-task/tap/go-task`
        - Windows: `choco install go-task -y` or `scoop install task`
        - Curl: `sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin`
        - Go: `go install github.com/go-task/task/v3/cmd/task@latest`

- Run `task` and see a list of all the pre-built tasks.

This will simplify your setup and running of the project.
For example, to get started, just run:

```shell
task init
```

This will download the models with the resume option using curl (allowing it to continue if interuppted without restarting from scratch), followed by running the required docker commands.

## Features


### AUTOMATIC1111

[AUTOMATIC1111's fork](https://github.com/AUTOMATIC1111/stable-diffusion-webui) is imho the most feature rich yet elegant UI:

- Text to image, with many samplers and even negative prompts!
- Image to image, with masking, cropping, in-painting, out-painting, variations.
- GFPGAN, RealESRGAN, LDSR, CodeFormer.
- Loopback, prompt weighting, prompt matrix, X/Y plot
- Live preview of the generated images.
- Highly optimized 4GB GPU support, or even CPU only!
- [Full feature list here](https://github.com/AUTOMATIC1111/stable-diffusion-webui-feature-showcase)

| Text to image                                                                                              | Image to image                                                                                             | Extras                                                                                                     |
| ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| ![](https://user-images.githubusercontent.com/24505302/189541954-46afd772-d0c8-4005-874c-e2eca40c02f2.jpg) | ![](https://user-images.githubusercontent.com/24505302/189541956-5b528de7-1b5d-479f-a1db-d3f5a53afc59.jpg) | ![](https://user-images.githubusercontent.com/24505302/189541957-cf78b352-a071-486d-8889-f26952779a61.jpg) |

### hlky

[hlky's fork](https://github.com/hlky/stable-diffusion-webui) is one of the most popular UIs, with many features:

- Text to image, with many samplers
- Image to image, with masking, cropping, in-painting, variations.
- GFPGAN, RealESRGAN, LDSR, GoBig, GoLatent
- Loopback, prompt weighting
- 6GB or even 4GB GPU support!
- [Full feature list here](https://github.com/sd-webui/stable-diffusion-webui/blob/master/README.md)

Screenshots:

| Text to image                                                                                              | Image to image                                                                                             | Image Lab                                                                                                  |
| ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| ![](https://user-images.githubusercontent.com/24505302/189541298-f902b021-a1eb-4e4b-b2eb-b6a696a8ec80.jpg) | ![](https://user-images.githubusercontent.com/24505302/189541295-7d7f2162-2189-4e0a-abbd-703f4779e1cd.jpg) | ![](https://user-images.githubusercontent.com/24505302/189541294-aa7f7735-a973-4e17-ada0-1fe3acbb1772.jpg) |

### lstein

[lstein's fork](https://github.com/lstein/stable-diffusion) is very mature when it comes to the cli, but less so for the WebUI.

## Setup & Usage

Visit the wiki for [Setup](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/Setup) and [Usage](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/Usage) instructions, checkout the [FAQ](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/FAQ) page if you face any problems, or create a new issue!

## Contributing
Contributions are welcome! create an issue first of what you want to contribute (before you implement anything) so we can talk about it.

## Disclaimer

The authors of this project are not responsible for any content generated using this interface.

This license of this software forbids you from sharing any content that violates any laws, produce any harm to a person, disseminate any personal information that would be meant for harm, spread misinformation and target vulnerable groups. For the full list of restrictions please read [the license](./LICENSE).

## Thanks

Special thanks to everyone behind these awesome projects, without them, none of this would have been possible:

- [hlky/stable-diffusion-webui](https://github.com/hlky/stable-diffusion-webui)
- [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [lstein/stable-diffusion](https://github.com/lstein/stable-diffusion)
- [CompVis/stable-diffusion](https://github.com/CompVis/stable-diffusion)
- [hlky/sd-enable-textual-inversion](https://github.com/hlky/sd-enable-textual-inversion)
- [devilismyfriend/latent-diffusion](https://github.com/devilismyfriend/latent-diffusion)
- [Hafiidz/latent-diffusion](https://github.com/Hafiidz/latent-diffusion)
