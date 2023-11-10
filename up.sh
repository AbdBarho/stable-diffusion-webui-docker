#!/bin/bash

# Stop execution if any command fails
set -e

# Define variables
SERVICE_NAME="auto"
NEW_TAG="v$(date +%s)" # Using a timestamp as the version tag for simplicity

git pull


# Build the new Docker image with the new tag
docker compose --profile download up -d --build
docker compose --profile auto build $SERVICE_NAME

# Tag the new image
docker tag $SERVICE_NAME:latest $SERVICE_NAME:$NEW_TAG

# Bring up the new containers in detached mode, without affecting the other services
docker compose  --profile auto up -d --no-deps --build $SERVICE_NAME

OLD_CONTAINERS=$(docker images --filter "reference=$SERVICE_NAME" --filter "before=$SERVICE_NAME:$NEW_TAG" --format "{{.Repository}}:{{.Tag}}")

# Remove the old containers
if [ -n "$OLD_CONTAINERS" ]; then
    echo "Removing old containers..."
    docker rmi $OLD_CONTAINERS
fi

echo "Deployment completed successfully."

