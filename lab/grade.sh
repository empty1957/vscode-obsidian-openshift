#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0

check() {
  local name=$1
  shift
  if "$@" >/tmp/grade.out 2>/tmp/grade.err; then
    printf 'PASS: %s\n' "$name"
    PASS=$((PASS + 1))
  else
    printf 'FAIL: %s\n' "$name"
    sed 's/^/  /' /tmp/grade.err
    FAIL=$((FAIL + 1))
  fi
}

check "Task 1 deployment exists with nginx:1.27 and 2 replicas" bash -c '
  [[ $(kubectl -n app-team get deploy web -o jsonpath={.spec.replicas}) == 2 ]]
  [[ $(kubectl -n app-team get deploy web -o jsonpath={.spec.template.spec.containers[0].image}) == nginx:1.27 ]]
'

check "Task 2 service exposes web on port 80" bash -c '
  [[ $(kubectl -n app-team get svc web-svc -o jsonpath={.spec.type}) == ClusterIP ]]
  [[ $(kubectl -n app-team get svc web-svc -o jsonpath={.spec.ports[0].port}) == 80 ]]
  [[ $(kubectl -n app-team get svc web-svc -o jsonpath={.spec.ports[0].targetPort}) == 80 ]]
'

check "Task 3 ConfigMap and pod mount are present" bash -c '
  [[ $(kubectl -n lab get configmap app-config -o jsonpath={.data.message}) == cka-practice ]]
  kubectl -n lab get pod config-reader -o json | jq -e '\''
    .spec.volumes[]? | select(.configMap.name == "app-config")
  '\'' >/dev/null
  kubectl -n lab get pod config-reader -o json | jq -e '\''
    .spec.containers[].volumeMounts[]? | select(.mountPath == "/etc/config")
  '\'' >/dev/null
'

check "Task 4 NetworkPolicy restricts backend ingress from lab clients" bash -c '
  kubectl -n restricted get networkpolicy allow-lab-client -o json | jq -e '\''
    .spec.podSelector.matchLabels.app == "backend" and
    (.spec.ingress[]?.from[]? | select(.podSelector.matchLabels.access == "allowed")) and
    (.spec.ingress[]?.from[]? | select(.namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "lab"))
  '\'' >/dev/null
'

check "Task 5 PVC requests 1Gi ReadWriteOnce" bash -c '
  [[ $(kubectl -n storage get pvc data -o jsonpath={.spec.resources.requests.storage}) == 1Gi ]]
  kubectl -n storage get pvc data -o json | jq -e '\''.spec.accessModes | index("ReadWriteOnce")'\'' >/dev/null
'

printf '\nScore: %d passed, %d failed\n' "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]]
