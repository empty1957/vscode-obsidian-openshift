# Upgrade Runbook

OpenShift更新作業のランブックです。

## Before Upgrade

- 現在バージョンと更新先を確認します。
- ClusterOperatorの状態を確認します。
- 既知の非互換、Deprecated API、Operator更新条件を確認します。
- バックアップ取得状況を確認します。

## During Upgrade

```bash
oc get clusterversion
oc get co
oc get nodes
```

## After Upgrade

- ClusterOperatorがAvailableになっているか確認します。
- NodeがReadyか確認します。
- 主要アプリケーションのヘルスチェックを実施します。
- 変更点を [[80-decisions/_index|Decisions]] または運用ログへ記録します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Kubernetes Debugging: https://kubernetes.io/docs/tasks/debug/

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[20-architecture/operators|Operators]]

