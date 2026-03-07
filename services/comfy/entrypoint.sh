#!/bin/bash

# Creates the directories for the models inside of the volume that is mounted from the host
echo "Creating directories for models..."
MODEL_DIRECTORIES=(
    "checkpoints"
    "clip"
    "clip_vision"
    "configs"
    "controlnet"
    "diffusers"
    "diffusion_models"
    "embeddings"
    "gligen"
    "hypernetworks"
    "loras"
    "photomaker"
    "style_models"
    "text_encoders"
    "unet"
    "upscale_models"
    "vae"
    "vae_approx"
)
for MODEL_DIRECTORY in ${MODEL_DIRECTORIES[@]}; do
    mkdir -p /opt/comfyui/models/$MODEL_DIRECTORY
done

# Creates the symlink for the ComfyUI Manager to the custom nodes directory, which is also mounted from the host
echo "Creating symlink for ComfyUI Manager..."
rm --force /opt/comfyui/custom_nodes/ComfyUI-Manager
ln -s \
    /opt/comfyui-manager \
    /opt/comfyui/custom_nodes/ComfyUI-Manager

# The custom nodes that were installed using the ComfyUI Manager may have requirements of their own, which are not installed when the container is
# started for the first time; this loops over all custom nodes and installs the requirements of each custom node
echo "Installing requirements for custom nodes..."
for CUSTOM_NODE_DIRECTORY in /opt/comfyui/custom_nodes/*;
do
    if [ "$CUSTOM_NODE_DIRECTORY" != "/opt/comfyui/custom_nodes/ComfyUI-Manager" ];
    then
        if [ -f "$CUSTOM_NODE_DIRECTORY/requirements.txt" ];
        then
            CUSTOM_NODE_NAME=${CUSTOM_NODE_DIRECTORY##*/}
            CUSTOM_NODE_NAME=${CUSTOM_NODE_NAME//[-_]/ }
            echo "Installing requirements for $CUSTOM_NODE_NAME..."
            pip install --no-cache-dir --requirement "$CUSTOM_NODE_DIRECTORY/requirements.txt"
        fi
    fi
done

# Under normal circumstances, the container would be run as the root user, which is not ideal, because the files that are created by the container in
# the volumes mounted from the host, i.e., custom nodes and models downloaded by the ComfyUI Manager, are owned by the root user; the user can specify
# the user ID and group ID of the host user as environment variables when starting the container; if these environment variables are set, a non-root
# user with the specified user ID and group ID is created, and the container is run as this user
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ];
then
    echo "Running container as root"
    exec "$@"
else
#    echo "Creating non-root user..."
#    getent group $GROUP_ID > /dev/null 2>&1 || groupadd --gid $GROUP_ID comfyui-user
#    id -u $USER_ID > /dev/null 2>&1 || useradd --uid $USER_ID --gid $GROUP_ID --create-home comfyui-user
#    chown --recursive $USER_ID:$GROUP_ID /opt/comfyui
#    chown --recursive $USER_ID:$GROUP_ID /opt/comfyui-manager
#    export PATH=$PATH:/home/comfyui-user/.local/bin
#    sudo --set-home --preserve-env=PATH --user \#$USER_ID "$@"

    echo "Running container as $USER_ID:$GROUP_ID"
    exec "$@"
fi
