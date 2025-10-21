#!/bin/bash
# Author: Gleb Denisov
# Description: This script builds Blog app and pushes it to Docker repository (AMD + Mac M2)

IMAGE_NAME=blog-web-app
TAG=${1:-latest}
USERNAME=gl3b
PLATFORMS="linux/amd64,linux/arm64"

# Ensure Buildx builder exists
docker buildx inspect multiarch-builder >/dev/null 2>&1 || docker buildx create --name multiarch-builder --use

# Build image for multiple architectures
docker buildx build --platform $PLATFORMS -t $USERNAME/$IMAGE_NAME:$TAG --load .
if [ $? -ne 0 ];then
  echo "ERROR: Failed to build $IMAGE_NAME"
  exit 1
else
  echo "[*] $IMAGE_NAME successfully built."
fi

# Push to Docker hub
docker push $USERNAME/$IMAGE_NAME:$TAG
if [ $? -ne 0 ];then
  echo "ERROR: Failed to push $IMAGE_NAME to Docker hub"
  exit 1
else
  echo "[*] $IMAGE_NAME successfully pushed"
fi
