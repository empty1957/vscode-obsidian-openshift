#!/usr/bin/env bash
set -euo pipefail

for _ in $(seq 1 120); do
  if kubectl get nodes >/dev/null 2>&1; then
    kubectl wait --for=condition=Ready node --all --timeout=120s >/dev/null
    exit 0
  fi
  sleep 1
done

echo "K3s did not become ready. Last log lines:" >&2
tail -80 /var/log/k3s.log >&2 || true
exit 1
