# Cluster Health Check

OpenShift クラスターの状態を短時間で確認し、異常がある場合に次の調査へ進むための初動ランブックです。定例点検、変更作業前後、障害一次切り分けで同じ順序を使います。

## Preconditions

- `oc` CLI で対象クラスターへログイン済みであること
- ClusterOperator、Node、Pod、Event を参照できる権限があること
- サポートケースへ連携する可能性がある場合は、`cluster-admin` 権限での証跡取得可否を確認しておくこと

## Quick Check

```bash
oc whoami
oc get clusterversion
oc get co
oc get nodes
oc get pods -A
oc get events -A --sort-by=.lastTimestamp
```

## Checkpoints

- `oc get clusterversion` で `Available=True`、かつ意図しない更新中や失敗履歴がないか
- `oc get co` で `Degraded=True` の ClusterOperator がないか
- `oc get co` で `Progressing=True` が長時間残っている ClusterOperator がないか
- `oc get nodes` で `NotReady`、`SchedulingDisabled`、想定外の `Ready,SchedulingDisabled` がないか
- `oc get pods -A` で `CrashLoopBackOff`、`ImagePullBackOff`、`Pending`、想定外の `Completed` が増えていないか
- `oc get events -A --sort-by=.lastTimestamp` で同じ Warning が繰り返されていないか

## When Something Looks Wrong

異常を見つけたら、最初に「どの層で止まっているか」を分けます。

| 観点 | 追加コマンド | 見るポイント |
| --- | --- | --- |
| ClusterOperator | `oc describe co <name>` | `Degraded` / `Progressing` の理由、関連 Namespace、直近メッセージ |
| Node | `oc describe node <node>` | `Conditions`、DiskPressure、MemoryPressure、NetworkUnavailable、kubelet 関連 Event |
| Pod | `oc describe pod -n <namespace> <pod>` | Scheduling、Image pull、Probe、Volume mount のどこで失敗しているか |
| Namespace 単位 | `oc get all,events -n <namespace>` | Deployment、ReplicaSet、Service、Route、Event の整合性 |
| Update 中 | `oc adm upgrade` | 更新対象バージョン、更新可否、更新が止まっている理由 |

## Evidence Collection

一次切り分けで原因が見えない、または Red Hat Support へ連携する場合は、調査ログを早めに固定します。

```bash
oc get clusterversion -o jsonpath='{.items[].spec.clusterID}{"\n"}'
oc adm must-gather
oc adm inspect ns/<namespace>
```

- Cluster ID はサポートケースでクラスターを一意に識別するために控えます。
- `oc adm must-gather` はクラスター全体の診断情報を収集します。実行後に生成されたディレクトリを圧縮して保管します。
- 影響範囲が特定 Namespace に限られる場合は、`oc adm inspect ns/<namespace>` で対象を絞った証跡も残します。
- Secret、証明書、顧客データを含む可能性があるため、共有先と保管場所を事前に決めます。

## Operational Notes

- 変更作業前後のヘルスチェックでは、同じコマンドを同じ順序で実行し、差分として比較できるようにします。
- Warning Event は古いものも残るため、時刻、対象 Object、繰り返し回数を合わせて判断します。
- `Progressing=True` は更新やロールアウト中にも発生するため、継続時間と変更作業の予定を照合します。
- 障害対応では、原因調査の前に影響範囲、開始時刻、直近変更、復旧優先度をメモします。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Kubernetes Debugging: https://kubernetes.io/docs/tasks/debug/

## Related

- [[60-troubleshooting/pod-crashloopbackoff|Pod CrashLoopBackOff]]
- [[60-troubleshooting/imagepullbackoff|ImagePullBackOff]]
- [[30-operations/upgrade-runbook|Upgrade Runbook]]

## References

- [OpenShift Container Platform 4.19: Gathering data about your cluster](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/support/gathering-cluster-data)
- [OpenShift Container Platform 4.19: Troubleshooting a cluster update](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/updating_clusters/troubleshooting-a-cluster-update)
