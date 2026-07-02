#!/usr/bin/env bash
set -euo pipefail

export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}

if [[ "${1:-}" == "--help" ]]; then
  cat /opt/cka-sim/questions.md
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "This simulator must run as root inside the container." >&2
  exit 1
fi

mkdir -p /etc/rancher/k3s /var/lib/rancher/k3s

if ! pgrep -x k3s >/dev/null 2>&1; then
  echo "Starting local K3s cluster..."
  /usr/local/bin/k3s server \
    --disable traefik \
    --disable servicelb \
    --write-kubeconfig-mode 644 \
    >/var/log/k3s.log 2>&1 &
fi

/opt/cka-sim/wait-ready.sh
/opt/cka-sim/setup.sh

cat <<'BANNER'

CKA Practice Simulator is ready.
Commands: questions | status | grade | reset-lab

BANNER

exec /bin/bash -l
