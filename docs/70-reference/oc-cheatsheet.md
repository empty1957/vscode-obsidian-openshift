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

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift CLI documentation: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/cli_tools/openshift-cli-oc
- kubectl command reference: https://kubernetes.io/docs/reference/kubectl/

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]

