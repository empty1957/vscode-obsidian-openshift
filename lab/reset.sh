#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace app-team --ignore-not-found >/dev/null
kubectl -n lab delete pod config-reader --ignore-not-found >/dev/null
kubectl -n lab delete configmap app-config --ignore-not-found >/dev/null
kubectl -n restricted delete networkpolicy allow-lab-client --ignore-not-found >/dev/null
kubectl -n storage delete pvc data --ignore-not-found >/dev/null
/opt/cka-sim/setup.sh
echo "Lab reset complete."
