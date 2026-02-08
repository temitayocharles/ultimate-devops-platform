#!/usr/bin/env bash
set -euo pipefail
umask 027

# Optional: start Docker daemon inside the container.
# Requires --privileged or equivalent permissions.
if [[ "${ENABLE_DOCKERD:-false}" == "true" ]]; then
  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "[INFO] Starting Docker daemon..."
    sudo /usr/sbin/dockerd >/tmp/dockerd.log 2>&1 &
    sleep 2
  fi
fi

# Optional: start UI (static page) on port 8080
if [[ "${UI_ENABLED:-false}" == "true" ]]; then
  UI_PORT="${UI_PORT:-8080}"
  if command -v python3 >/dev/null 2>&1; then
    echo "[INFO] Starting UI on port ${UI_PORT}..."
    (cd /opt/ui && python3 -m http.server "${UI_PORT}") >/tmp/ui.log 2>&1 &
  else
    echo "[WARN] python3 not found; UI cannot start."
  fi
fi

exec "$@"
