# Project Resource Quota

ProjectまたはNamespaceにResourceQuotaとLimitRangeを設定し、リソース消費を制御するRunbookです。

## Purpose

特定ProjectのCPU、メモリ、Pod数、PVC数などを制限し、単一チームや単一アプリケーションによるクラスタ全体への影響を抑えます。

## Preconditions

- 対象Project名と利用チームを確認済みであること。
- 既存Podのrequests/limits設定状況を確認していること。
- 制限値について利用者と合意していること。

## Steps

1. 対象Projectの現状を確認します。

```bash
oc project <project-name>
oc get pods
oc describe quota
oc describe limitrange
```

2. 現在のリソース要求量を確認します。

```bash
oc adm top pod -n <project-name>
oc get pod -n <project-name> -o custom-columns=NAME:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory
```

3. ResourceQuotaを作成します。

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-default-quota
  namespace: <project-name>
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "30"
    persistentvolumeclaims: "10"
```

4. LimitRangeを作成します。

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: project-default-limits
  namespace: <project-name>
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      default:
        cpu: 500m
        memory: 512Mi
```

5. 適用します。

```bash
oc apply -f quota.yaml
oc apply -f limitrange.yaml
```

## Rollback

問題が出た場合は、作成したResourceQuotaまたはLimitRangeを削除します。

```bash
oc delete resourcequota project-default-quota -n <project-name>
oc delete limitrange project-default-limits -n <project-name>
```

## Verification

```bash
oc describe quota -n <project-name>
oc describe limitrange -n <project-name>
oc get events -n <project-name> --sort-by=.lastTimestamp
```

Pod作成が意図通り制限され、既存ワークロードに不要な再起動が発生していないことを確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Resource Quotas: https://kubernetes.io/docs/concepts/policy/resource-quotas/
- Kubernetes Limit Ranges: https://kubernetes.io/docs/concepts/policy/limit-range/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
