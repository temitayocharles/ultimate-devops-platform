#!/usr/bin/env bash
set -euo pipefail
umask 027

is_truthy() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

# Optional: start Docker daemon inside the container.
# Requires --privileged or equivalent permissions.
DOCKERD_ENABLE="${ENABLE_DOCKERD:-}"
if [[ -z "$DOCKERD_ENABLE" ]]; then
  DOCKERD_ENABLE="${DEVOPS_DOCKER:-}"
fi
if [[ -z "$DOCKERD_ENABLE" ]]; then
  DOCKERD_ENABLE="${DEVOPS_UI:-}"
fi

if is_truthy "$DOCKERD_ENABLE"; then
  export DOCKER_HOST="unix:///var/run/docker.sock"
  if [[ ! -S /var/run/docker.sock ]]; then
    echo "[INFO] Starting Docker daemon..."
    sudo /usr/sbin/dockerd >/tmp/dockerd.log 2>&1 &
    sleep 2
  fi
fi

# Optional: start UI (static page) on port 8080
UI_ENABLE="${UI_ENABLED:-}"
if [[ -z "$UI_ENABLE" ]]; then
  UI_ENABLE="${DEVOPS_UI:-}"
fi
if is_truthy "$UI_ENABLE"; then
  UI_PORT="${UI_PORT:-8080}"
  if command -v python3 >/dev/null 2>&1; then
    echo "[INFO] Starting UI on port ${UI_PORT}..."
    (cd /opt/ui && python3 -m http.server "${UI_PORT}") >/tmp/ui.log 2>&1 &
  else
    echo "[WARN] python3 not found; UI cannot start."
  fi
fi

exec "$@"
