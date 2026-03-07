#!/usr/bin/env bash

# Check if GPU type is provided
if [ $# -eq 0 ]; then
    >&2 echo "Error: GPU type not specified. Please use 'amd' or 'nv' as an argument."
    exit 1
fi

GPU_TYPE=$1

# Validate GPU type
if [ "$GPU_TYPE" != "amd" ] && [ "$GPU_TYPE" != "nv" ]; then
    >&2 echo "Error: Invalid GPU type. Please use 'amd' or 'nv'."
    exit 1
fi

mkdir dlbackend

# Creates the symlink for the ComfyUI directory
echo "Creating symlink for ComfyUI..."
rm --force ${CUSTOM_NODES_PATH}/ComfyUI-Manager
ln -s \
    /opt/comfyui \
    ${COMFYUI_PATH}

echo "Creating symlink for ComfyUI Manager..."
rm --force ${CUSTOM_NODES_PATH}/ComfyUI-Manager
ln -s \
    /opt/comfyui-manager \
    ${CUSTOM_NODES_PATH}/ComfyUI-Manager

#cd ComfyUI
cd ${COMFYUI_PATH}

# Try to find a good python executable, and dodge unsupported python versions
for pyvers in python3.11 python3.10 python3.12 python3 python
do
    python=`which $pyvers`
    if [ "$python" != "" ]; then
        break
    fi
done
if [ "$python" == "" ]; then
    >&2 echo "ERROR: cannot find python3"
    >&2 echo "Please follow the install instructions in the readme!"
    exit 1
fi

# Validate venv
venv=`$python -m venv 2>&1`
case $venv in
    *usage*)
        :
    ;;
    *)
        >&2 echo "ERROR: python venv is not installed"
        >&2 echo "Please follow the install instructions in the readme!"
        >&2 echo "If on Ubuntu/Debian, you may need: sudo apt install python3-venv"
        exit 1
    ;;
esac

# Make and activate the venv. "python3" in the venv is now the python executable.
if [ -z "${SWARM_NO_VENV}" ]; then
    echo "Making venv..."
    $python -s -m venv venv
    source venv/bin/activate
    python=python3
    python3 -m ensurepip --upgrade
else
    echo "swarm_no_venv set, will not create venv"
fi

# Install PyTorch based on GPU type
if [ "$GPU_TYPE" == "nv" ]; then
    echo "install nvidia torch..."
    $python -s -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128
elif [ "$GPU_TYPE" == "amd" ]; then
    echo "install amd torch..."
    $python -s -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3
fi

echo "install general requirements..."
$python -s -m pip install --no-cache-dir \
    opencv-python \
    diffusers \
    triton \
    torchsde \
    nvidia-ml-py \
    sageattention \
    psutil \
    nvitop

# Installs the required Python packages for both ComfyUI and the ComfyUI Manager
$python -s -m pip install --no-cache-dir \
    --requirement ${COMFYUI_PATH}/requirements.txt \
    --requirement ${CUSTOM_NODES_PATH}/ComfyUI-Manager/requirements.txt

# Pre-install previously used custom nodes requirements from volume
if [ -f "/docker/requirements.txt" ]; then
  echo "pre-install custom nodes requirements..."
  $python -s -m pip install --no-cache-dir -r /docker/requirements.txt
elif [ "$GPU_TYPE" == "amd" ]; then
  echo "merged-requirements.txt not found, skipping pre-install."
fi

echo "Installation completed for $GPU_TYPE GPU."
