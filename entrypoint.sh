#!/usr/bin/env bash
set -e

# Optional: start Docker daemon inside the container.
# Requires --privileged or equivalent permissions.
if [[ "${ENABLE_DOCKERD:-false}" == "true" ]]; then
  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "[INFO] Starting Docker daemon..."
    sudo dockerd >/tmp/dockerd.log 2>&1 &
    sleep 2
  fi
fi

exec "$@"
