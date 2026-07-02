# Backup and Restore

バックアップとリストア方針を整理します。

## Scope

- etcdバックアップ
- アプリケーションデータ
- マニフェスト、Helm values、Kustomize overlays
- Secretや外部依存の復旧手順

## Questions

- RPOとRTOはいくつか
- バックアップの保存先はどこか
- リストア手順を検証した日時はいつか
- クラスタ全体復旧とNamespace単位復旧のどちらが必要か

## Runbook Skeleton

1. 対象範囲を確認します。
2. バックアップ取得状態を確認します。
3. リストア先を準備します。
4. データを復元します。
5. アプリケーション疎通を確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Kubernetes Storage: https://kubernetes.io/docs/concepts/storage/

## Related

- [[20-architecture/storage|Storage]]

