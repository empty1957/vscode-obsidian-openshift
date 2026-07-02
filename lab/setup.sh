#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl create namespace storage --dry-run=client -o yaml | kubectl apply -f - >/dev/null

kubectl -n restricted create deployment backend --image=nginx:1.27 --replicas=2 --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl -n restricted label deployment backend app=backend --overwrite >/dev/null

kubectl -n lab create deployment client --image=busybox:1.36 -- /bin/sh -c 'sleep 3600' --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl -n lab label deployment client access=allowed --overwrite >/dev/null
