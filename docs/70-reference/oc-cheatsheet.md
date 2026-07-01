# oc Cheatsheet

よく使う`oc`コマンドのメモです。

## Login and Context

```bash
oc login <api-url>
oc whoami
oc project
oc projects
oc project <project-name>
```

## Inspect

```bash
oc get all
oc get pods -o wide
oc describe pod <pod-name>
oc logs <pod-name>
oc logs deploy/<deployment-name>
```

## Apply

```bash
oc apply -f <file>
oc delete -f <file>
oc rollout status deploy/<deployment-name>
oc rollout undo deploy/<deployment-name>
```

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]

