# General

Unfortunately, AMD GPUs [#63](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/63) and MacOs [#35](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/35) are not supported, contributions to add support are very welcome.

## `auto` exists with error code 137

This is an indicator that the container does not have enough RAM, you need at least 12GB, recommended 16GB.

You might need to [adjust the size of the docker virtual machine RAM](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/296#issuecomment-1480318829) depending on your OS.

## Dockerfile parse error
```
Error response from daemon: dockerfile parse error line 33: unknown instruction: GIT
ERROR: Service 'model' failed to build : Build failed
```
Update docker to the latest version, and make sure you are using `docker compose` instead of `docker-compose`. [#16](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/16), also, try setting the environment variable `DOCKER_BUILDKIT=1`

## Unknown Flag `--profile`

Update docker to the latest version, and see [this comment](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/165#issuecomment-1296155667), try setting the environment variable mentioned in the previous point.

## Output is a always green image
use `--precision full --no-half`. [#9](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/9)


## Found no NVIDIA driver on your system even though the drivers are installed and `nvidia-smi` shows it

add `NVIDIA_DRIVER_CAPABILITIES=compute,utility` and `NVIDIA_VISIBLE_DEVICES=all` to container can resolve this problem [#348](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/348#issuecomment-1449250332)


---

# Linux

### Error response from daemon: could not select device driver "nvidia" with capabilities: `[[gpu]]`

Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and restart the docker service [#81](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/81) 


### `docker compose --profile auto up --build` fails with `OSError`

This might be related to the `overlay2` storage driver used by docker overlayed on zfs, change to the `zfs` storage driver [#433](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/433#issuecomment-1694520689)

---

# Windows / WSL


## Build fails at [The Shell command](https://github.com/AbdBarho/stable-diffusion-webui-docker/blob/5af482ed8c975df6aa0210225ad68b218d4f61da/build/Dockerfile#L11), `/bin/bash` not found in WSL.

Edit the corresponding docker file, and change the SHELL from `/bin/bash` to `//bin/bash` [#21](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/21), note: this is a hack and something in your wsl is messed up.


## Build fails with credentials errors when logged in via SSH on WSL2/Windows
You can try forcing plain text auth creds storage by removing line with "credStore" from ~/.docker/config.json (in WSL). [#56](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/56)

## `unable to access 'https://github.com/...': Could not resolve host: github.com` or any domain
Set the `build/network` of the service you are starting to `host` [#114](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/114#issue-1393683083)

## Other build errors on windows
* Make sure:
   * Windows 10 release >= 2021H2 (required for WSL to see the GPU)
   * WSL2 (check with `wsl -l -v`)
   * Latest Docker Desktop
* You might need to create a [`.wslconfig`](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#example-wslconfig-file) and increase memory, if you have 16GB RAM, set the limit to something around 12GB, [#34](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/34) [#64](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/64)
* You might also need to [force wsl to allow file permissions](https://superuser.com/a/1646556)

---

# AWS

You have to use one of AWS's GPU-enabled VMs and their Deep Learning OS images. These have the right divers, the toolkit and all the rest already installed and optimized. [#70](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/70)
