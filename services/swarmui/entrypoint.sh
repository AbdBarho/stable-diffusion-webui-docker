#!/usr/bin/env bash
# Ensure correct local path.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

# Add dotnet non-admin-install to path
export PATH="$SCRIPT_DIR/.dotnet:~/.dotnet:$PATH"

# Default env configuration, gets overwritten by the C# code's settings handler
export ASPNETCORE_ENVIRONMENT="Production"
export ASPNETCORE_URLS="http://*:7801"

chmod -R 755 ${COMFYUI_PATH}/user/default/
chmod -R 755 /opt/comfyui/user/default/

echo "Using Python at: $(which python)"
echo "Python version: $(python --version)"

# The custom nodes that were installed using the ComfyUI Manager may have requirements of their own, which are not installed when the container is
# started for the first time; this loops over all custom nodes and installs the requirements of each custom node
echo "Installing requirements for custom nodes..."
for CUSTOM_NODE_DIRECTORY in ${CUSTOM_NODES_PATH}/*;
do
    if [ "$CUSTOM_NODE_DIRECTORY" != "${CUSTOM_NODES_PATH}/ComfyUI-Manager" ];
    then
        if [ -f "$CUSTOM_NODE_DIRECTORY/requirements.txt" ];
        then
            CUSTOM_NODE_NAME=${CUSTOM_NODE_DIRECTORY##*/}
            CUSTOM_NODE_NAME=${CUSTOM_NODE_NAME//[-_]/ }
            echo "Installing requirements for $CUSTOM_NODE_NAME..."
            python3 -s -m pip install --requirement "$CUSTOM_NODE_DIRECTORY/requirements.txt"
        fi
    fi
done

# Actual runner.
cd "$HOME"
dotnet ./bin/SwarmUI.dll "$@"

# Exit code 42 means restart, anything else = don't.
if [ $? == 42 ]; then
    . /entrypoint.sh "$@"
fi
