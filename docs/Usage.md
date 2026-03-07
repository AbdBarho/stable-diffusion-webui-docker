Assuming you [setup everything correctly](https://github.com/AbdBarho/stable-diffusion-webui-docker/wiki/Setup), you can run any UI (interchangeably, but not in parallel) using the command:
```bash
docker compose --profile [ui] up --build
```
where `[ui]` is one of `auto`, `auto-cpu`, `comfy`, or `comfy-cpu`.

### Mounts

The `data` and `output` folders are always mounted into the container as `/data` and `/output`, use them so if you want to transfer anything from / to the container.

### Updates
if you want to update to the latest version, just pull the changes
```bash
git pull
```

You can also checkout specific tags if you want.

### Customization
If you want to customize the behaviour of the uis, you can create a `docker-compose.override.yml` and override  whatever you want from the [main `docker-compose.yml` file](https://github.com/AbdBarho/stable-diffusion-webui-docker/blob/master/docker-compose.yml). Example:

```yml
services:
   auto:
     environment:
       - CLI_ARGS=--lowvram
```

Possible configuration:

# `auto`
By default: `--medvram` is given, which allow you to use this model on a 6GB GPU, you can also use `--lowvram` for lower end GPUs. Remove these arguments if you are using a (relatively) high end GPU, like 40XX series cards, as these arguments will slow you down.

[You can find the full list of cli arguments here.](https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/modules/shared.py)

### Custom models

Put the weights in the folder `data/StableDiffusion`, you can then change the model from the settings tab.

### General Config
There is multiple files in  `data/config/auto` such as `config.json` and `ui-config.json` which let you which contain additional config for the UI.

### Scripts
put your scripts `data/config/auto/scripts` and restart the container

### Extensions

You can use the UI to install extensions, or, you can put your extensions in `data/config/auto/extensions`.

Different extensions require additional dependencies. Some of them might conflict with each other and changing versions of packages could break things. This container will try to install missing extension dependencies on startup, but it won't resolve any problems for you.

There is also the option to create a script `data/config/auto/startup.sh` which will be called on container startup, in case you want to install any additional dependencies for your extensions or anything else.


An example of your `startup.sh` might looks like this:
```sh
#!/bin/bash

# opencv-python-headless to not rely on opengl and drivers.
pip install -q --force-reinstall opencv-python-headless
```

NOTE: dependencies of extensions might get lost when you create a new container, hence the installing them in the startup script is important.

It is not recommended to modify the Dockerfile for the sole purpose of supporting some extension (unless you truly know what you are doing).

### **DONT OPEN AN ISSUE IF A SCRIPT OR AN EXTENSION IS NOT WORKING**

I maintain neither the UI nor the extension, I can't help you.


# `auto-cpu`
CPU instance of the above, some stuff might not work, use at your own risk.
