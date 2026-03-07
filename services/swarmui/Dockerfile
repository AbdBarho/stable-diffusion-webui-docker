ARG SWARMUI_VERSION=0.9.7-Beta
ARG COMFYUI_VERSION=v0.8.2
#ARG COMFYUI_MANAGER_VERSION=3.35
ARG DOTNET_VERSION=9.0-bookworm-slim
#ARG DOTNET_VERSION=8.0-bookworm-slim
ARG ASPNET_VERSION=9.0-bookworm-slim
#ARG ASPNET_VERSION=8.0-bookworm-slim
ARG SWARM_PATH="/SwarmUI"

# BUILD
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
ARG SWARM_PATH
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y git

WORKDIR ${SWARM_PATH}

# Clones the SwarmUI repository and checks out the latest release
RUN git clone --depth=1 https://github.com/mcmonkeyprojects/SwarmUI.git ${SWARM_PATH} && \
    cd ${SWARM_PATH} && \
    git fetch origin ${SWARMUI_VERSION} && \
    git checkout FETCH_HEAD

RUN dotnet build src/SwarmUI.csproj --configuration Release -o ./bin

# RUN
FROM mcr.microsoft.com/dotnet/aspnet:${ASPNET_VERSION}
ARG SWARM_PATH
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

ENV USER_NAME="root"
#ENV USER="swarmui"
ENV GROUP_NAME="root"
ARG SWARMUI_USER_ID=1000
ARG SWARMUI_GROUP_ID=1000

ARG GPU_TYPE="nv"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""

#RUN addgroup --gid $SWARMUI_GROUP_ID swarmui && \
#    adduser --uid $SWARMUI_USER_ID --gid $SWARMUI_GROUP_ID --gecos "" --disabled-password swarmui

COPY --from=build ${SWARM_PATH} "${SWARM_PATH}/"

RUN mkdir -p "${SWARM_PATH}/Data"
RUN chown -R $(id -u):$(id -g) ${SWARM_PATH}
#RUN chown -R ${USER_NAME}:${GROUP_NAME} ${SWARM_PATH}
#RUN chown -R swarmui:swarmui ${SWARM_PATH}
ENV HOME=${SWARM_PATH}

RUN --mount=type=cache,target=/var/cache/apt \
    apt update --assume-yes && \
    apt install -y \
        git \
        wget \
        build-essential \
        python3.11 \
        python3.11-venv \
        python3.11-dev \
        python3-pip \
        ffmpeg  \
        libglib2.0-0 \
        libgl1

# Install ComfyUI
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /opt/comfyui && \
    cd /opt/comfyui && \
    git fetch origin ${COMFYUI_VERSION} && \
    git checkout FETCH_HEAD

RUN git clone --depth=1 https://github.com/Comfy-Org/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager
#    cd /opt/comfyui-manager && \
#    git fetch origin ${COMFYUI_MANAGER_VERSION} && \
#    git checkout FETCH_HEAD

WORKDIR ${SWARM_PATH}
RUN chown -R $(id -u):$(id -g) /opt/comfyui
#RUN chown -R ${USER_NAME}:${GROUP_NAME} /opt/comfyui
RUN git config --global --add safe.directory /opt/comfyui

ENV COMFYUI_PATH="/SwarmUI/dlbackend/ComfyUI"
#ENV COMFYUI_PATH="/SwarmUI/dlbackend/ComfyUI"
ENV CUSTOM_NODES_PATH="/SwarmUI/dlbackend/ComfyUI/custom_nodes"

# Pre-install previously used custom nodes requirements from volume
COPY ./install/merged-requirements.txt* /docker/requirements.txt
COPY comfy-install-linux.sh ${SWARM_PATH}/launchtools/
RUN chmod +x ${SWARM_PATH}/launchtools/comfy-install-linux.sh && \
    ${SWARM_PATH}/launchtools/comfy-install-linux.sh ${GPU_TYPE}

RUN chown -R $(id -u):$(id -g) ${SWARM_PATH}
#RUN chown -R ${USER_NAME}:${GROUP_NAME} /opt/comfyui
#RUN chown -R swarmui:swarmui ${SWARM_PATH} # Reapplied again bc of permissions issues, maybe related to a symlink/docker/windows bug
#RUN chown -R swarmui:swarmui ${COMFYUI_PATH} # Reapplied again bc of permissions issues, maybe related to a symlink/docker/windows bug
#RUN chown -R swarmui:swarmui ${COMFYUI_PATH}/venv # Reapplied again bc of permissions issues, maybe related to a symlink/docker/windows bug
ENV PATH="${COMFYUI_PATH}/venv/bin:$PATH"
ENV PYTHONPATH="${CUSTOM_NODES_PATH}:\${PYTHONPATH}"
#USER swarmui
EXPOSE 7801

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh", "--launch_mode", "none", "--host", "0.0.0.0"]
