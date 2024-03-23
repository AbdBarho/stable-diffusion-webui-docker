FROM alpine/git:2.36.2 as download

COPY clone.sh /clone.sh

# RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf
RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
RUN . /clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f
RUN . /clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git 6f7db241d2f8ba7457bac5ca9753331f0c266917

# Image for Mac M1 arch
FROM ubuntu:22.04

# Set env vars
ARG GRADIO_SERVER_PORT=7860

# These settings prevent a timezone prompt when Python installs
ENV TZ=US/Pacific \
    DEBIAN_FRONTEND=noninteractive \
    GRADIO_SERVER_PORT=${GRADIO_SERVER_PORT} \
    PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    # we need those
    apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
    # extensions needs those
    ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential \
    # Install AUTOMATIC1111 pre-requisites
    cmake rustc git-all wget apt-utils pip \
    # Install Python pre-requisites, including Python 3.x; Google perftools includes TCMalloc, which helps with CPU memory usage
    software-properties-common python3 python3-pip python3-ipykernel libopencv-dev python3-opencv python3.10-venv google-perftools sudo

# Install AUTOMATIC1111 pre-requisites
# RUN apt-get install -y jq
RUN apt -y autoremove && apt autoclean

# Configure git
RUN git config --global user.name "Some One" &&\
    git config --global user.email some.one@some.one &&\
    git config --global init.defaultBranch main

RUN sudo apt purge -y gcc libomp-dev
# RUN export USE_OPENMP=1
# ENV USE_OPENMP=1
RUN sudo apt-get install gcc libomp-dev -y

# # Check versions
# RUN echo |cpp -fopenmp -dM |grep -i open
# RUN gcc --version

RUN echo "deb http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/ trusty main" | sudo tee /etc/apt/sources.list.d/ibm-xl-compiler-eval.list
# RUN sudo apt-get update

RUN "/usr/bin/python3" -m pip install torch==2.1.2 torchvision==0.16.2 --extra-index-url https://download.pytorch.org/whl/cu121

WORKDIR /
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui && \
    git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5 && \
    pip install -r requirements_versions.txt

ENV ROOT=/stable-diffusion-webui

COPY --from=download /repositories/ ${ROOT}/repositories/
# COPY --from=download /models/ ${ROOT}/models/
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -r ${ROOT}/repositories/CodeFormer/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install pyngrok \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@v2.20.0

# TODO: Use `sed` instead of copying files
# Modify code from AUTOMATIC1111 repo as needed for Mac M1
COPY paths_internal.py /stable-diffusion-webui/modules/paths_internal.py
COPY sd_models.py /stable-diffusion-webui/modules/sd_models.py
COPY webui-macos-env.sh /stable-diffusion-webui/webui-macos-env.sh
COPY webui-user.sh /stable-diffusion-webui/webui-user.sh

# ENTRYPOINT [ "/bin/bash" ]

# IS THIS NEEDED?
COPY webui.sh /stable-diffusion-webui/webui.sh

RUN chmod 777 -R /stable-diffusion-webui/

EXPOSE 7860

RUN export OPENBLAS_NUM_THREADS=1
WORKDIR /stable-diffusion-webui
RUN git config --global --add safe.directory "*"

# RUN useradd -s /bin/bash -d /home/sdwui/ -m -G sudo sdwui
# USER sdwui
# RUN git config --global --add safe.directory "*"

####################################################################################################
# TODO: Clean this mess
##################################################
# RUN site_pkg_loc=`python -m site | grep 'site-packages' | head -1 | awk -F"'" '{print $2}' -`; mv frpc_linux_aarch64_v0.2 `echo $site_pkg_loc`/gradio/frpc_linux_aarch64_v0.2; chmod +x `echo $site_pkg_loc`/gradio/frpc_linux_aarch64_v0.2
RUN "/usr/bin/python3" -m pip install gradio==3.41.2 && \
    curl -LS https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_aarch64 -o frpc_linux_aarch64_v0.2 && \
    chmod +x frpc_linux_aarch64_v0.2
##################################################
RUN if [ -d /usr/local/lib/python3.10/dist-packages/gradio/ ]; then scp frpc_linux_aarch64_v0.2 /usr/local/lib/python3.10/dist-packages/gradio/.; fi
RUN if [ -d /usr/lib/python3/dist-packages/gradio ]; then scp frpc_linux_aarch64_v0.2 /usr/lib/python3.10/dist-packages/gradio/.; fi
RUN if [ -d /usr/lib/python3.10/dist-packages/gradio ]; then scp frpc_linux_aarch64_v0.2 /usr/lib/python3.10/dist-packages/gradio/.; fi
RUN if [ -d /home/sdwui/.local/lib/python3.10/site-packages/gradio ]; then scp frpc_linux_aarch64_v0.2 /home/sdwui/.local/lib/python3.10/site-packages/gradio/.; fi
##################################################
RUN if [ -d /home/sdwui/.local/lib/python3.10/site-packages/gradio ]; then \
        GRADIO_DIR_PATH=/home/sdwui/.local/lib/python3.10/site-packages/gradio \
    else \
        GRADIO_DIR_PATH=/usr/lib/python3/dist-packages/gradio; fi && \
    mv frpc_linux_aarch64_v0.2 ${GRADIO_DIR_PATH}/frpc_linux_aarch64_v0.2 && \
    chmod +x ${GRADIO_DIR_PATH}/frpc_linux_aarch64_v0.2
####################################################################################################

RUN export USE_OPENMP=1
RUN export OPENBLAS_NUM_THREADS=1
ENV USE_OPENMP=1 \
    OPENBLAS_NUM_THREADS=1


####################################################################################################
### This is done above, in `download`
##################################################
# RUN mkdir -p ${ROOT}/repositories
# COPY clone.sh ${ROOT}/.
# WORKDIR ${ROOT}
# RUN chmod +x ${ROOT}/clone.sh


# RUN ./clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
#     && rm -rf assets inputs
# RUN ./clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf
# RUN ./clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
# RUN ./clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
# RUN ./clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
# RUN ./clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f

# RUN ./clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git 6f7db241d2f8ba7457bac5ca9753331f0c266917
# # Copy them over, cuz stable-diffusion-webui-assets isnt getting added proplerly
# RUN scp -r /repositories/* ${ROOT}/repositories/.
####################################################################################################

# TODO: test if this is needed
RUN "/usr/bin/python3" -m pip install clip
# VERSION: clip @ git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1


COPY . /docker

# TMP DO THIS SO DOWNLOAD TIMES ARE FASTER WHILE TESTING; for local dev
# COPY sd-v1-4.ckpt ${ROOT}/models/Stable-diffusion/sd-v1-4.ckpt

WORKDIR ${ROOT}
# ENTRYPOINT [ "/bin/bash" ]
RUN ln -s /data/models/Stable-diffusion ${ROOT}/models/Stable-diffusion
# TODO: link outputs to mounted output volume
CMD /usr/bin/python3 -u webui.py --listen --port 7860