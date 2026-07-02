# Storage

OpenShiftで利用する永続ストレージの整理です。

## Concepts

- PersistentVolumeClaim: アプリケーションが要求するストレージ
- PersistentVolume: 実体のストレージ
- StorageClass: 動的プロビジョニングの方式
- Access Mode: RWO、RWX、ROXなどのマウント方式

## Design Questions

- データはPod再作成後も必要か
- 複数Podから同時書き込みが必要か
- バックアップとリストアの責任範囲はどこか
- 性能要件と容量増加の見込みはどれくらいか

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Kubernetes Storage: https://kubernetes.io/docs/concepts/storage/

## Related

- [[30-operations/backup-and-restore|Backup and Restore]]

