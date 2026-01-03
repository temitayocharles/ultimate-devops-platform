#!/bin/bash
set -euo pipefail

IMAGE_TAG="temitayocharles/devops-charlie:latest"

echo "[INFO] Tagging image..."
docker tag devops-charlie "$IMAGE_TAG"

echo "[INFO] Pushing to Docker Hub..."
docker push "$IMAGE_TAG"

echo "[DONE] Image available at: https://hub.docker.com/r/temitayocharles/devops-charlie"
