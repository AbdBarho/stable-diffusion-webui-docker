#!/bin/bash

# detect if build-essential is missing or broken
if ! dpkg-query -W -f'${Status}' "build-essential" 2>/dev/null | grep -q "ok installed"; then
echo "build-essential not found or broken!

A C++ compiler is required to build needed Python packages!
To install one, run cmd_wsl.bat and enter these commands:

sudo apt-get update
sudo apt-get install build-essential
"
read -n1 -p "Continue the installer anyway? [y,n]" EXIT_PROMPT
# only continue if user inputs 'y' else exit
if ! [[ $EXIT_PROMPT == "Y" || $EXIT_PROMPT == "y" ]]; then exit; fi
fi

# deactivate existing conda envs as needed to avoid conflicts
{ conda deactivate && conda deactivate && conda deactivate; } 2> /dev/null

# config   unlike other scripts, can't use current directory due to file IO bug in WSL, needs to be in virtual drive
INSTALL_DIR_PREFIX="$HOME/text-gen-install"
if [[ ! $(realpath "$(pwd)/..") = /mnt/* ]]; then
    INSTALL_DIR_PREFIX="$(realpath "$(pwd)/..")" && INSTALL_INPLACE=1
fi
INSTALL_DIR="$INSTALL_DIR_PREFIX/text-generation-webui"
CONDA_ROOT_PREFIX="$INSTALL_DIR/installer_files/conda"
INSTALL_ENV_DIR="$INSTALL_DIR/installer_files/env"
MINICONDA_DOWNLOAD_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh"
conda_exists="F"

# environment isolation
export PYTHONNOUSERSITE=1
unset PYTHONPATH
unset PYTHONHOME
export CUDA_PATH="$INSTALL_ENV_DIR"
export CUDA_HOME="$CUDA_PATH"

# /usr/lib/wsl/lib needs to be added to LD_LIBRARY_PATH to fix years-old bug in WSL where GPU drivers aren't linked properly
export LD_LIBRARY_PATH="$CUDA_HOME/lib:/usr/lib/wsl/lib:$LD_LIBRARY_PATH"

# open bash cli if called with 'wsl.sh cmd' with workarounds for existing conda
if [ "$1" == "cmd" ]; then
    exec bash --init-file <(echo ". ~/.bashrc; conda deactivate 2> /dev/null; cd $INSTALL_DIR || cd $HOME; source $CONDA_ROOT_PREFIX/etc/profile.d/conda.sh; conda activate $INSTALL_ENV_DIR")
    exit
fi

if [[ "$INSTALL_DIR" =~ " " ]]; then echo This script relies on Miniconda which can not be silently installed under a path with spaces. && exit; fi

# create install dir if missing
if [ ! -d "$INSTALL_DIR" ]; then mkdir -p "$INSTALL_DIR" || exit; fi

# figure out whether git and conda needs to be installed
if "$CONDA_ROOT_PREFIX/bin/conda" --version &>/dev/null; then conda_exists="T"; fi

# (if necessary) install git and conda into a contained environment
# download miniconda
if [ "$conda_exists" == "F" ]; then
    echo "Downloading Miniconda from $MINICONDA_DOWNLOAD_URL to $INSTALL_DIR/miniconda_installer.sh"

    curl -Lk "$MINICONDA_DOWNLOAD_URL" > "$INSTALL_DIR/miniconda_installer.sh"

    chmod u+x "$INSTALL_DIR/miniconda_installer.sh"
    bash "$INSTALL_DIR/miniconda_installer.sh" -b -p $CONDA_ROOT_PREFIX

    # test the conda binary
    echo "Miniconda version:"
    "$CONDA_ROOT_PREFIX/bin/conda" --version
fi

# create the installer env
if [ ! -e "$INSTALL_ENV_DIR" ]; then
    "$CONDA_ROOT_PREFIX/bin/conda" create -y -k --prefix "$INSTALL_ENV_DIR" python=3.11 git
fi

# check if conda environment was actually created
if [ ! -e "$INSTALL_ENV_DIR/bin/python" ]; then
    echo "Conda environment is empty."
    exit
fi

# activate installer env
source "$CONDA_ROOT_PREFIX/etc/profile.d/conda.sh" # otherwise conda complains about 'shell not initialized' (needed when running in a script)
conda activate "$INSTALL_ENV_DIR"

pushd $INSTALL_DIR 1> /dev/null || exit

if [ ! -f "./server.py" ]; then
    git init -b main
    git remote add origin https://github.com/oobabooga/text-generation-webui
    git fetch
    git remote set-head origin -a
    git reset origin/HEAD --hard
    git branch --set-upstream-to=origin/HEAD
    git restore -- . :!./CMD_FLAGS.txt
fi

# copy CMD_FLAGS.txt to install dir to allow edits within Windows
if [[ $INSTALL_INPLACE != 1 ]]; then
    # workaround for old install migration
    if [ ! -f "./wsl.sh" ]; then
        git pull || exit
        [ -f "../webui.py" ] && mv "../webui.py" "../webui-old.py"
    fi
    if [ -f "$(dirs +1)/CMD_FLAGS.txt" ] && [ -f "./CMD_FLAGS.txt" ]; then cp -u "$(dirs +1)/CMD_FLAGS.txt" "$INSTALL_DIR"; fi
fi

# setup installer env   update env if called with 'wsl.sh update'
case "$1" in
("update") python one_click.py --update;;
(*) python one_click.py $@;;
esac
