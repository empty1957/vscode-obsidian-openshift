#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes -o wide
printf '\nNamespaces:\n'
kubectl get ns app-team lab restricted storage --ignore-not-found
printf '\nHelpers: questions | grade | reset-lab\n'
