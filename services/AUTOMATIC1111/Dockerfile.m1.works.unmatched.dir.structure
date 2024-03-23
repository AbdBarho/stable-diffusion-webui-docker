
# docker build -t sdwui:test -f Dockercleaned .
# docker run -it -p 7860:7861 sdwui:test
# FROM alpine/git:2.36.2 as download

# COPY clone.sh /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh


# # RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
# #   && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif
# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf

# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
#   && rm -rf assets inputs

# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f

###################################################################################################################################################
###################################################################################################################################################
###################################################################################################################################################
FROM ubuntu:22.04

# Set env vars
ARG GRADIO_SERVER_PORT=7860
ENV GRADIO_SERVER_PORT=${GRADIO_SERVER_PORT}

# These settings prevent a timezone prompt when Python installs
ENV TZ=US/Pacific \
    DEBIAN_FRONTEND=noninteractive

RUN echo "#################################################"
RUN echo "Get the latest APT packages"
RUN echo "apt-get update"
RUN apt-get update

# Install AUTOMATIC1111 pre-requisites
RUN apt-get install -y \
    cmake \
    rustc \
    git-all \
    wget \
    apt-utils \
    jq \
    pip

RUN apt -y autoremove && apt autoclean

# Install Python pre-requisites, including Python 3.x
# Google perftools includes TCMalloc, which helps with CPU memory usage
RUN apt-get install -y \
    software-properties-common \ 
    python3 \
    python3-pip \
    python3-ipykernel \
    libopencv-dev \
    python3-opencv \
    python3.10-venv \
    google-perftools \
    sudo

RUN apt -y autoremove && apt autoclean

# Configure git
RUN git config --global user.name "Some One" &&\
    git config --global user.email some.one@some.one &&\
    git config --global init.defaultBranch main

RUN sudo apt purge gcc -y
RUN sudo apt purge libomp-dev -y
RUN export USE_OPENMP=1
ENV USE_OPENMP=1
RUN sudo apt-get install gcc libomp-dev -y

# Check versions
RUN echo |cpp -fopenmp -dM |grep -i open
RUN gcc --version

RUN echo "deb http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/ trusty main" | sudo tee /etc/apt/sources.list.d/ibm-xl-compiler-eval.list
RUN sudo apt-get update

RUN "/usr/bin/python3" -m pip install torch==2.1.2 torchvision==0.16.2 --extra-index-url https://download.pytorch.org/whl/cu121

# RUN mkdir -p /home/stable_diffusion_webui/stable-diffusion-webui
# WORKDIR /home/stable_diffusion_webui
#
#
#
# REPLACE COPY WITH GIT CLONE
#       https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/bef51aed032c0aaa5cfd80445bc4cf0d85b408b5
RUN mkdir -p /home/stable_diffusion_webui
WORKDIR /home/stable_diffusion_webui
# COPY clone.sh /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh
# RUN . /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh stable-diffusion-webui https://github.com/AUTOMATIC1111/stable-diffusion-webui.git bef51aed032c0aaa5cfd80445bc4cf0d85b408b5
# RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/stable_diffusion_webui/stable-diffusion-webui
# WORKDIR /home/stable_diffusion_webui/stable-diffusion-webui
# RUN git checkout bef51aed032c0aaa5cfd80445bc4cf0d85b408b5
# WORKDIR /home/stable_diffusion_webui
# Using their way
# RUN --mount=type=cache,target=/root/.cache/pip \
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/stable_diffusion_webui/stable-diffusion-webui && \
  cd /home/stable_diffusion_webui/stable-diffusion-webui && \
  git reset --hard bef51aed032c0aaa5cfd80445bc4cf0d85b408b5 && \
  pip install -r requirements_versions.txt
#   cd -
RUN "/usr/bin/python3" -m pip install -r /home/stable_diffusion_webui/stable-diffusion-webui/requirements_versions.txt
WORKDIR /home/stable_diffusion_webui



# Modify code from AUTOMATIC1111 repo as needed for Mac M1
COPY paths_internal.py /home/stable_diffusion_webui/stable-diffusion-webui/modules/paths_internal.py
COPY sd_models.py /home/stable_diffusion_webui/stable-diffusion-webui/modules/sd_models.py
COPY webui-macos-env.sh /home/stable_diffusion_webui/stable-diffusion-webui/webui-macos-env.sh
COPY webui-user.sh /home/stable_diffusion_webui/stable-diffusion-webui/webui-user.sh

# IS THIS NEEDED?
COPY webui.sh /home/stable_diffusion_webui/stable-diffusion-webui/webui.sh

RUN chmod 777 -R /home/stable_diffusion_webui/stable-diffusion-webui/

EXPOSE 7860

RUN export OPENBLAS_NUM_THREADS=1
WORKDIR /home/stable_diffusion_webui/stable-diffusion-webui
RUN git config --global --add safe.directory "*"

# RUN useradd -s /bin/bash -d /home/sdwui/ -m -G sudo sdwui
# USER sdwui
# RUN git config --global --add safe.directory "*"
# RUN ./webui.sh
# RUN source /home/stable_diffusion_webui/stable-diffusion-webui/webui-macos-env.sh
# RUN source source /home/stable_diffusion_webui/stable-diffusion-webui/webui-user.sh

# RUN "/usr/bin/python3" -m pip install -r requirements_versions.txt

# # Need to be after `webui.sh` installs reqs like gradio
# RUN curl -LS https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_aarch64 -o frpc_linux_aarch64_v0.2
# # ENTRYPOINT [ "/bin/bash" ]
# # ENV python=/usr/bin/python3
# # RUN site_pkg_loc=`python -m site | grep 'site-packages' | head -1 | awk -F"'" '{print $2}' -`; mv frpc_linux_aarch64_v0.2 `echo $site_pkg_loc`/gradio/frpc_linux_aarch64_v0.2; chmod +x `echo $site_pkg_loc`/gradio/frpc_linux_aarch64_v0.2
# RUN mv frpc_linux_aarch64_v0.2 /home/sdwui/.local/lib/python3.10/site-packages/gradio/.
# RUN mv frpc_linux_aarch64_v0.2 /home/sdwui/.local/lib/python3.10/site-packages/gradio/.
# RUN chmod +x /home/sdwui/.local/lib/python3.10/site-packages/gradio/frpc_linux_aarch64_v0.2

####################################################################################################
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

# RUN mv /home/stable_diffusion_webui/stable-diffusion-webui /stable-diffusion-webui
# WORKDIR /stable-diffusion-webui

# RUN useradd -s /bin/bash -d /home/sdwui/ -m -G sudo sdwui
# USER sdwui
# RUN git config --global --add safe.directory "*"

# COPY entrypoint.sh /home/stable_diffusion_webui/entrypoint.sh

RUN export USE_OPENMP=1
ENV USE_OPENMP=1
RUN export OPENBLAS_NUM_THREADS=1
ENV OPENBLAS_NUM_THREADS=1





RUN mkdir -p /home/stable_diffusion_webui/stable-diffusion-webui/repositories
COPY clone.sh /home/stable_diffusion_webui/stable-diffusion-webui/.
WORKDIR /home/stable_diffusion_webui/stable-diffusion-webui
RUN chmod +x /home/stable_diffusion_webui/stable-diffusion-webui/clone.sh

# RUN git clone https://github.com/Stability-AI/stablediffusion.git \
#     && cd stablediffusion && \
#     && git reset --hard cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
#     && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif .git \
#     && cd .. \
#     && mkdir /home/stable_diffusion_webui/stable-diffusion-webui/repositories \
#     && mv stablediffusion /home/stable_diffusion_webui/stable-diffusion-webui/repositories/stable-diffusion-stability-ai

RUN ./clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git c5b4593074ba6214284d6acd5f1719b6c5d739af \
    && rm -rf assets inputs
RUN ./clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf
RUN ./clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN ./clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
RUN ./clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
RUN ./clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f
RUN ./clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git 6f7db241d2f8ba7457bac5ca9753331f0c266917
RUN mv /repositories/* /home/stable_diffusion_webui/stable-diffusion-webui/repositories/.

RUN "/usr/bin/python3" -m pip install clip



############################################################################################################################################
##############
### REMOVE ###
##############
# COPY sd-v1-4.ckpt /home/stable_diffusion_webui/stable-diffusion-webui/models/Stable-diffusion/sd-v1-4.ckpt
############################################################################################################################################





# RUN export COMMANDLINE_ARGS="--skip-torch-cuda-test --opt-sdp-attention --precision full --no-half --upcast-sampling --no-half-vae --use-cpu interrogate"
# ENV COMMANDLINE_ARGS="--skip-torch-cuda-test --opt-sdp-attention --precision full --no-half --upcast-sampling --no-half-vae --use-cpu interrogate"
# CMD /usr/bin/python3 -u webui.py --listen --port 7860 ${COMMANDLINE_ARGS}
CMD /usr/bin/python3 -u webui.py --listen --port 7860
# ENTRYPOINT [ "/bin/bash" ]