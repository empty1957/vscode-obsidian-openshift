# Backup and Restore

OpenShift のバックアップとリストアは、クラスタ制御面の復旧とアプリケーション単位の復旧を分けて設計します。etcd バックアップはクラスタ状態を災害復旧するための最後の砦であり、Namespace、PVC、アプリケーション設定を日常的に戻す用途では OpenShift API for Data Protection (OADP) などのアプリケーションバックアップを使います。

## Scope

| 対象 | 主な手段 | 戻せるもの | 注意点 |
| --- | --- | --- | --- |
| Control plane / etcd | etcd snapshot | Kubernetes / OpenShift API オブジェクトのクラスタ状態 | 同じ障害シナリオで PV や外部 DB のデータ整合性まで保証するものではない |
| アプリケーション Namespace | OADP `Backup` / `Restore` | Namespace 内の Kubernetes リソース、内部イメージ、PV | object storage、snapshot API、CSI snapshot、Kopia / Restic などの前提を確認する |
| GitOps マニフェスト | Git リポジトリ | desired state、Helm values、Kustomize overlays | Secret や外部依存の復旧方法は別に持つ |
| 外部 DB / SaaS | 製品ごとのバックアップ | アプリケーションデータ | OpenShift 側の `Restore` と復旧時刻を合わせる |

## Design Questions

- RPO と RTO は Namespace、アプリケーション、外部 DB ごとに定義されているか。
- etcd snapshot はどこに退避し、クラスタ障害時に誰が取得場所へアクセスできるか。
- OADP のバックアップ保存先 object storage は、対象クラスタ喪失時にも利用できる場所か。
- PV は CSI snapshot で戻すのか、Kopia / Restic などのファイルシステムバックアップで戻すのか。
- GitOps 管理リソースを `Restore` したあと、Argo CD などが上書きする設計になっていないか。
- Secret、証明書、外部接続情報をバックアップへ含める場合、暗号化、保持期限、閲覧権限は妥当か。

## etcd Backup

etcd は OpenShift の API オブジェクト状態を保持します。クラスタ停止、重大な誤削除、control plane の quorum loss などに備え、公式手順に従って snapshot を取得し、クラスタ外へ退避します。

```bash
oc get clusterversion
oc get co
oc get nodes
```

運用上は、次の情報を backup 台帳へ残します。

- 取得日時、OpenShift バージョン、cluster ID
- 取得した control plane node
- snapshot と static pod resource の保存先
- 保存先の暗号化、保持期限、復旧担当者
- restore 手順を最後に検証した日付

etcd restore はクラスタ状態を過去へ戻す強い操作です。古い snapshot を戻すと、実際の PV、外部 DB、外部ロードバランサ、DNS、GitOps の状態とずれる可能性があります。実行前に障害範囲、復旧時刻、アプリケーションデータの整合性を確認します。

## Application Backup with OADP

OADP は Namespace 粒度で Kubernetes リソース、内部イメージ、PV をバックアップ / リストアするための仕組みです。バックアップ保存先として object storage が必要で、PV を snapshot で保護する場合はクラウドまたは CSI の snapshot 機能が前提になります。

```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: app-a-daily
  namespace: openshift-adp
spec:
  includedNamespaces:
    - app-a
  storageLocation: default
  ttl: 168h0m0s
```

```yaml
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: app-a-restore-20260719
  namespace: openshift-adp
spec:
  backupName: app-a-daily
  includedNamespaces:
    - app-a
```

バックアップ設計では、単に `Backup` CR を作るだけでなく、restore 先でアプリケーションが起動できるかを検証します。特に StatefulSet、PVC、Route、TLS Secret、外部 DB 接続、Operator 管理リソースは、復旧直後に差分が出やすいポイントです。

## Restore Drill

1. 復旧対象 Namespace、復旧時刻、依存する外部システムを確認します。
2. 現在の状態を保存します。

```bash
oc get all,pvc,route,secret,configmap -n <namespace>
oc get events -n <namespace> --sort-by=.lastTimestamp
```

3. バックアップの存在、完了状態、保存場所を確認します。

```bash
oc get backup -n openshift-adp
oc describe backup -n openshift-adp <backup-name>
```

4. restore は可能なら検証用 Namespace または検証クラスタで先に実行します。
5. Pod 起動、PVC bind、Route 到達性、アプリケーションの読み書きを確認します。
6. GitOps 管理下のリソースは、restore 後に desired state と drift がないか確認します。
7. 復旧後、RPO / RTO の実績、失敗した手順、次回までの改善点を記録します。

## Common Pitfalls

| 症状 | 見るポイント | 対応の考え方 |
| --- | --- | --- |
| Restore 後に Pod が `Pending` | PVC、StorageClass、Node affinity、quota | restore 先クラスタで同じ storage 前提を満たす |
| Secret は戻ったが接続できない | 証明書期限、外部 DB 側の許可、DNS | Secret の値だけでなく外部依存も同じ時刻へ戻す |
| GitOps が restore 結果を上書きする | Argo CD / Application 状態 | restore 中は同期方針を明示し、復旧後に desired state を更新する |
| etcd restore 後にアプリデータが不整合 | PV / 外部 DB の更新時刻 | etcd snapshot とアプリデータの復旧ポイントを合わせる |
| Backup は成功するが restore が未検証 | drill 履歴、手順書、権限 | 定期的に検証 restore を行い、成功条件を数値で残す |

## Quality Checklist

- `Backup` と `Restore` の両方を検証している。
- RPO / RTO が実測値で更新されている。
- object storage、snapshot、暗号化、保持期限、アクセス権がレビューされている。
- Secret や証明書を含む場合の取り扱いがセキュリティ方針に合っている。
- 障害時に参照できる場所へ runbook と backup 台帳を置いている。

## Sources

- Red Hat OpenShift Container Platform 4.20 Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Red Hat OpenShift Container Platform 4.20 OADP Application backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/oadp-application-backup-and-restore
- Kubernetes Storage: https://kubernetes.io/docs/concepts/storage/

## Related

- [[20-architecture/storage|Storage]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[30-operations/upgrade-runbook|Upgrade Runbook]]
