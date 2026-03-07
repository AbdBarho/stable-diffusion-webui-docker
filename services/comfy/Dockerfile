# syntax=docker/dockerfile:1

# NOTE: Building this image require's docker version >= 23.0.
#
# For reference:
# - https://docs.docker.com/build/dockerfile/frontend/#stable-channel

# ------------------------------------------------------------
# Pytorch
# ------------------------------------------------------------
ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS dev-base

ENV BASE_VERSION=2404
ARG PYTHON_VERSION=3.11.10
ARG PYTORCH_VERSION=2.10.0
ARG TORCHVISION_VERSION=0.25.0
ARG CUDA_VERSION=12.8
ARG CUDA_PATH=cu128
ARG COMFYUI_VERSION=0.16.3

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_NO_CACHE_DIR=1
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        curl \
        git \
        libjpeg-dev \
        libpng-dev \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        liblzma-dev \
        tk-dev \
        xz-utils \
        llvm \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}

# Install Python 3.11
RUN pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION} && \
    python --version

# Remove PEP 668 restriction (safe in containers)
RUN rm -f /usr/lib/python*/EXTERNALLY-MANAGED
RUN /usr/sbin/update-ccache-symlinks
RUN mkdir /opt/ccache && ccache --set-config=cache_dir=/opt/ccache
RUN pip install --upgrade pip

# ------------------------------------------------------------
FROM dev-base AS python-deps

COPY requirements.txt requirements-build.txt ./
# Install Python packages to system Python
RUN pip install --upgrade --ignore-installed pip setuptools wheel && \
    pip install cmake pyyaml numpy ipython -r requirements.txt

# ------------------------------------------------------------
FROM dev-base AS submodule-update

ARG PYTORCH_VERSION
RUN git clone https://github.com/pytorch/pytorch.git /opt/pytorch && \
    cd /opt/pytorch && \
    git fetch origin v${PYTORCH_VERSION} && \
    git checkout FETCH_HEAD
WORKDIR /opt/pytorch
RUN git submodule update --init --recursive

# ------------------------------------------------------------
FROM python-deps AS pytorch-installs

ARG CUDA_PATH
ARG INSTALL_CHANNEL=whl
#ARG INSTALL_CHANNEL=whl/nightly
# Automatically set by buildx
ARG TARGETPLATFORM

# INSTALL_CHANNEL whl - release, whl/nightly - nightly, whl/test - test channels
RUN case ${TARGETPLATFORM} in \
         "linux/arm64")  pip install --extra-index-url https://download.pytorch.org/whl/cpu/  \
                            torch==${PYTORCH_VERSION}+${CUDA_PATH} \
                            torchvision==${TORCHVISION_VERSION}+${CUDA_PATH} \
                            torchaudio==${PYTORCH_VERSION}+${CUDA_PATH} ;; \
         *)              pip install --index-url https://download.pytorch.org/${INSTALL_CHANNEL}/${CUDA_PATH#.}/ \
                            torch==${PYTORCH_VERSION}+${CUDA_PATH} \
                            torchvision==${TORCHVISION_VERSION}+${CUDA_PATH} \
                            torchaudio==${PYTORCH_VERSION}+${CUDA_PATH} ;; \
    esac
RUN pip install torchelastic
RUN IS_CUDA=$(python3 -c 'import torch ; print(torch.cuda._is_compiled())'); \
    echo "Is torch compiled with cuda: ${IS_CUDA}"; \
    if test "${IS_CUDA}" != "True" -a ! -z "${CUDA_VERSION}"; then \
        exit 1; \
    fi

# ------------------------------------------------------------
FROM dev-base AS official

ARG PYTORCH_VERSION
ARG TRITON_VERSION
ARG TARGETPLATFORM
ARG CUDA_VERSION
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        libjpeg-dev \
        libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy pyenv + Python runtime + site-packages
COPY --from=pytorch-installs /root/.pyenv /root/.pyenv
RUN python --version && pip --version

RUN if test -n "${CUDA_VERSION}" -a "${TARGETPLATFORM}" != "linux/arm64"; then \
        apt-get update -qq && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gcc && \
        rm -rf /var/lib/apt/lists/*; \
    fi
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:$PATH
ENV PYTORCH_VERSION=${PYTORCH_VERSION}
WORKDIR /workspace

# ------------------------------------------------------------
# CUDA
# ------------------------------------------------------------
FROM official AS dev
ARG CUDA_VERSION
ARG BUILD_TYPE=dev

# Install CUDA toolkit
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget gnupg2 ca-certificates && \
    # Add NVIDIA repository
    NVARCH=$(uname -m | sed 's/x86_64/x86_64/' | sed 's/aarch64/sbsa/') && \
    wget -qO - https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${BASE_VERSION}/${NVARCH}/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${BASE_VERSION}/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    # Install CUDA toolkit
    CUDA_PKG_VERSION=$(echo ${CUDA_VERSION} | cut -d'.' -f1,2 | tr '.' '-') && \
    apt-get update && apt-get install -y --no-install-recommends \
        cuda-toolkit-${CUDA_PKG_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Configure LD
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

# Set CUDA environment (always set, needed even if CUDA already in base)
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
ENV CUDA_HOME=/usr/local/cuda

# Copy pytorch
COPY --from=submodule-update /opt/pytorch /opt/pytorch

# ------------------------------------------------------------
# ffmpeg
# ------------------------------------------------------------
FROM dev AS ffmpeg

RUN apt update --assume-yes &&  \
    apt install --assume-yes \
    pkg-config \
    nasm \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libaom-dev \
    libx264-dev \
    libx265-dev \
    libfdk-aac-dev \
    libnuma-dev \
    libssl-dev \
    libunistring-dev \
    zlib1g-dev \
    libc6-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install ffmpeg-nvidia adapter
RUN mkdir ~/nv && cd ~/nv && \
  git clone https://github.com/FFmpeg/nv-codec-headers.git && \
  cd nv-codec-headers && make install

# compile ffmpeg with cuda
ARG CPUS=10
RUN cd ~/nv && \
  git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/ && \
  cd ffmpeg && \
  ./configure \
    --enable-gpl \
    --enable-nonfree \
    --enable-cuda-nvcc \
    --enable-nvenc \
    --enable-nvdec \
    --enable-cuvid \
    --enable-gpl \
    --enable-gnutls \
    --enable-libaom \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libvorbis \
    --enable-libx264 \
    --enable-libx265 \
    --enable-static \
    --disable-shared \
    --pkg-config-flags="--static" \
    --prefix=/usr/local \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64" \
    --extra-libs="-lpthread -lm" \
    && \
  make -j $CPUS && \
  make install && ldconfig

# ------------------------------------------------------------
# ComfyUI & Manager
# ------------------------------------------------------------
FROM dev AS comfy

# Copy ffmpeg
COPY --from=ffmpeg /usr/local /usr/local

RUN apt-get update --assume-yes && \
    apt-get install --assume-yes \
    sudo \
    wget \
    unzip \
    cmake \
    build-essential \
    libsndio7.0 \
    libxv1 \
    libass9 \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    libvdpau1 \
    libaom3 \
    libfdk-aac2 \
    libmp3lame0 \
    libvorbis0a \
    libvorbisenc2 \
    libx264-164 \
    libx265-199 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Version & libs check
RUN python -c "import torch; import torchaudio; print('Torch:', torch.__version__); print('Audio:', torchaudio.__version__); print('CUDA:', torch.version.cuda); print('CUDA available:', torch.cuda.is_available())"
RUN ldd /usr/local/bin/ffmpeg | grep "not found" && exit 1 || true
RUN ldconfig && ffmpeg -encoders | grep nvenc

RUN pip install --no-cache-dir \
    comfy-env \
    ffmpy \
    pillow \
    img2texture \
    PyOpenGL \
    PyOpenGL_accelerate \
    diffusers \
    triton \
    torchsde \
    nvidia-ml-py \
    sageattention \
    packaging \
    ninja  \
    compel  \
    psutil \
    nvitop \
    https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.7.16/flash_attn-2.8.3%2Bcu128torch2.10-cp311-cp311-linux_x86_64.whl

# Clones the ComfyUI repository and checks out the latest release
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /opt/comfyui && \
    cd /opt/comfyui && \
    git fetch origin v${COMFYUI_VERSION} && \
    git checkout FETCH_HEAD

# Clones the ComfyUI Manager repository; ComfyUI Manager is an extension for ComfyUI that enables users to install
# custom nodes and download models directly from the ComfyUI interface; instead of installing it to "/opt/comfyui/custom_nodes/ComfyUI-Manager", which
# is the directory it is meant to be installed in, it is installed to its own directory; the entrypoint will symlink the directory to the correct
# location upon startup; the reason for this is that the ComfyUI Manager must be installed in the same directory that it installs custom nodes to, but
# this directory is mounted as a volume, so that the custom nodes are not installed inside of the container and are not lost when the container is
# removed; this way, the custom nodes are installed on the host machine
RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager
#    cd /opt/comfyui-manager && \
#    git fetch origin ${COMFYUI_MANAGER_VERSION} && \
#    git checkout FETCH_HEAD

# Installs the required Python packages for both ComfyUI and the ComfyUI Manager
RUN pip install --no-cache-dir \
    --requirement /opt/comfyui/requirements.txt \
    --requirement /opt/comfyui-manager/requirements.txt

# Pre-install previously used custom nodes requirements from volume
COPY ./install/merged-requirements.txt* /docker/requirements.txt
RUN sh -c '[ -f /docker/requirements.txt ] && pip install --no-cache-dir -r /docker/requirements.txt  \
    || echo "merged-requirements.txt not found, skipping pre-install."'

# Clean up & permissions
RUN rm -rf /root/.cache/pip
ARG USER_ID
ARG GROUP_ID
RUN chown -R $USER_ID:$GROUP_ID $PYENV_ROOT
RUN chown -R $USER_ID:$GROUP_ID /opt/comfyui \
 && chmod -R u+rwx /opt/comfyui
RUN chown -R $USER_ID:$GROUP_ID /opt/comfyui-manager \
 && chmod -R u+rwx /opt/comfyui-manager
RUN mkdir -p /.cache \
 && chown -R $USER_ID:$GROUP_ID /.cache \
 && chmod -R u+rwx /.cache
RUN mkdir -p /.cache/uv \
 && chown -R $USER_ID:$GROUP_ID /.cache/uv \
 && chmod -R u+rwx /.cache/uv
RUN mkdir -p /.config \
 && chown -R $USER_ID:$GROUP_ID /.config \
 && chmod -R u+rwx /.config

# Sets the working directory to the ComfyUI directory
WORKDIR /opt/comfyui
COPY . /docker/
RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml /opt/comfyui
ENV PYTHONPATH="\${PYTHONPATH}:\${PWD}" CLI_ARGS=""
EXPOSE 7861
USER $USER_ID

# Adds the startup script to the container; the startup script will create all necessary directories in the models and custom nodes volumes that were
# mounted to the container and symlink the ComfyUI Manager to the correct directory; it will also create a user with the same UID and GID as the user
# that started the container, so that the files created by the container are owned by the user that started the container and not the root user
ENTRYPOINT ["/bin/bash", "/docker/entrypoint.sh"]

# On startup, ComfyUI is started at its default port; the IP address is changed from localhost to 0.0.0.0, because Docker is only forwarding traffic
# to the IP address it assigns to the container, which is unknown at build time; listening to 0.0.0.0 means that ComfyUI listens to all incoming
# traffic; the auto-launch feature is disabled, because we do not want (nor is it possible) to open a browser window in a Docker container
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "7861", "--disable-auto-launch"]
