Thanks to [RedTopper](https://github.com/RedTopper) for this guide! [#352](https://github.com/AbdBarho/stable-diffusion-webui-docker/issues/352)


On an selinux machine like Fedora, append `:z` to the volume mounts. This tells selinux that the files are shared between containers (required for download and your UI of choice to access the same files). *Properly merging :z with an override will work in podman compose 1.0.7, specifically commit https://github.com/containers/podman-compose/commit/0b853f29f44b846bee749e7ae9a5b42679f2649f*

```yaml
x-base_service: &base_service
    volumes:
      - &v1 ./data:/data:z
      - &v2 ./output:/output:z
```

You'll also need to add the runtime and security opts to allow access to your GPU. This can be specified in an override, no new versions required! More information can be found at this RedHat post: [How to enable NVIDIA GPUs in containers](https://www.redhat.com/en/blog/how-use-gpus-containers-bare-metal-rhel-8).

```yaml
x-base_service: &base_service
    ...
    runtime: nvidia
    security_opt:
      - label=type:nvidia_container_t
```

I also had to add `,Z` to the pip/apt caches for them to work. On the first build everything will be fine without the fix, but on the second+ build, you may get a "file not found" when pip goes to install a package from the cache. Here's a script to do this easily, along with more info: https://github.com/RedTopper/Stable-Diffusion-Webui-Podman/blob/podman/selinux-cache.sh.

Lastly, delete all the services you don't want to use. *Using `--profile` will work in podman compose 1.0.7, specifically commit https://github.com/containers/podman-compose/commit/8d8df0bc2816d8e8fa142781d9018a06fe0d08ed*