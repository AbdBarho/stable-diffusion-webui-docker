# Make sure you have the *latest* version of docker and docker compose installed

TLDR:

clone this repo and run:
```bash
docker compose --profile download up --build
# wait until its done, then:
docker compose --profile [ui] up --build
# where [ui] is one of: auto | auto-cpu | comfy | comfy-cpu
```
if you don't know which ui to choose, `auto` is good start.

Then access from http://localhost:7860/

Unfortunately, AMD GPUs [#63](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/63) and Mac [#35](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/35) are not supported, contributions to add support are very welcome!!!!!!!!!! 


If you face any problems, check the [FAQ page](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/FAQ), or [create a new issue](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues).

### Detailed Steps

First of all, clone this repo, you can do this with `git`, or you can download a zip file. Please always use the most up-to-date state from the `master` branch. Even though we have releases, everything is changing and breaking all the time.


After cloning, open a terminal in the folder and run:

```
docker compose --profile download up --build
```
This will download all of the required models / files, and validate their integrity. You only have to download the data once (regardless of the UI). There are roughly 12GB of data to be downloaded.

Next, choose which UI you want to run (you can easily change later):
- `auto`:  The most popular fork, many features with neat UI, [Repo by AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- `auto-cpu`: for users without a GPU.
- `comfy`: A graph based workflow UI, very powerful, [Repo by comfyanonymous](https://github.com/comfyanonymous/ComfyUI)


After the download is done, you can run the UI using:
```bash
docker compose --profile [ui] up --build
# for example:
# docker compose --profile invoke up --build
# or
# docker compose --profile auto up --build
```

Will start the app on http://localhost:7860/. Feel free to try out the different UIs.


Note: the first start will take some time since other models will be downloaded, these will be cached in the `data` folder, so next runs are faster. First time setup might take between 15 minutes and 1 hour depending on your internet connection, other times are much faster, roughly 20 seconds.