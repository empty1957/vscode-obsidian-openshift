# Node Maintenance Drain

Nodeを保守対象にしてPodを退避し、作業後にスケジューリングを戻すRunbookです。

## Purpose

Node再起動、ハードウェア保守、OS/ファームウェア作業などの前に、対象Nodeから通常Podを安全に退避します。

## Preconditions

- `cluster-admin` またはNode操作権限があること。
- 対象Node名を確認済みであること。
- PodDisruptionBudgetにより退避できないPodがないか確認すること。
- Control Plane Nodeを扱う場合は、クラスタ冗長性とetcd quorumを確認すること。

## Steps

1. 対象Nodeと状態を確認します。

```bash
oc get nodes
oc describe node <node-name>
```

2. 影響を受けるPodを確認します。

```bash
oc get pods -A --field-selector spec.nodeName=<node-name> -o wide
oc get pdb -A
```

3. 新規Podが配置されないようにcordonします。

```bash
oc adm cordon <node-name>
```

4. DaemonSet管理Podとローカルデータを考慮してdrainします。

```bash
oc adm drain <node-name> --ignore-daemonsets --delete-emptydir-data --timeout=10m
```

5. 保守作業を実施します。

6. NodeがReadyに戻ったことを確認します。

```bash
oc get node <node-name>
oc get pods -A --field-selector spec.nodeName=<node-name> -o wide
```

7. スケジューリングを戻します。

```bash
oc adm uncordon <node-name>
```

## Rollback

drain前なら `oc adm uncordon <node-name>` で新規Pod配置を戻します。drain後に保守を中止する場合は、NodeをReadyに戻してからuncordonします。

## Verification

```bash
oc get nodes
oc get co
oc get pods -A | grep -v Running
```

Nodeが `Ready`、ClusterOperatorが安定、退避対象Podが再配置済みであることを確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Safely Drain a Node: https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/
- Kubernetes Pod Disruption Budget: https://kubernetes.io/docs/tasks/run-application/configure-pdb/

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[30-operations/upgrade-runbook|Upgrade Runbook]]
- [[60-troubleshooting/pod-crashloopbackoff|Pod CrashLoopBackOff]]
