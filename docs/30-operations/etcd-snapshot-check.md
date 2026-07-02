# etcd Snapshot Check

etcd snapshotの取得状態と保管状況を確認するRunbookです。

## Purpose

Control Plane障害や災害復旧に備え、etcd backupが取得できる状態か、取得済みsnapshotが保管されているかを定期確認します。

## Preconditions

- `cluster-admin` 相当の権限があること。
- Control Plane Nodeへdebugできること。
- snapshotの保存先、保管期間、暗号化方針が決まっていること。

## Steps

1. etcd ClusterOperatorの状態を確認します。

```bash
oc get co etcd
oc describe co etcd
```

2. Control Plane Nodeを確認します。

```bash
oc get nodes -l node-role.kubernetes.io/master=
```

3. 取得先ディレクトリを決めます。

```bash
export BACKUP_DIR=/home/core/backup
```

4. Control Plane Node上でbackup scriptを実行します。

```bash
oc debug node/<master-node-name>
chroot /host
mkdir -p ${BACKUP_DIR}
/usr/local/bin/cluster-backup.sh ${BACKUP_DIR}
exit
exit
```

5. snapshotとstatic pod resourcesが作成されたことを確認します。

```bash
oc debug node/<master-node-name>
chroot /host
ls -lh /home/core/backup
exit
exit
```

## Rollback

snapshot取得のみならRollbackは不要です。不要な検証ファイルを削除する場合は、保存先と保管ルールを確認してから削除します。

## Verification

```bash
oc get co etcd
oc get nodes
```

snapshotファイルとstatic pod resources archiveが存在し、etcd Operatorが `Available=True` かつ `Degraded=False` であることを確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- OpenShift Backup and restore: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/backup_and_restore/backup-restore-overview
- Kubernetes etcd documentation: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

## Related

- [[30-operations/backup-and-restore|Backup and Restore]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[30-operations/upgrade-runbook|Upgrade Runbook]]
