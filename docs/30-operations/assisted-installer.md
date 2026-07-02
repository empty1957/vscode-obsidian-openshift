# Assisted Installer Operations

RHACMまたはmulticluster engineのHubクラスタでAssisted Installerを運用する場合の確認ポイントです。設計モデルは [[20-architecture/assisted-installer-hive-integration|Assisted Installer Hive Integration]] を参照します。

## Scope

このノートでは、Assisted InstallerをRHACM/MCE + Hive連携として扱います。Hub上の `ClusterDeployment`、`AgentClusterInstall`、`InfraEnv`、`Agent`、`NMStateConfig` を確認しながら、Spokeクラスタの作成状態を追います。

## Primary Checks

```bash
oc get clusterdeployment -A
oc get agentclusterinstall -A
oc get infraenv -A
oc get agent -A
oc get managedcluster
```

対象namespaceを絞って確認します。

```bash
NS=<cluster-namespace>
oc get clusterdeployment -n $NS
oc get agentclusterinstall -n $NS
oc get infraenv -n $NS
oc get agent -n $NS -o wide
```

## Cluster Install Conditions

```bash
oc get agentclusterinstall <name> -n <namespace> -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.message}{"\n"}{end}'
```

見る条件です。

- `SpecSynced`: `AgentClusterInstall` の内容がAssisted Serviceへ同期されているか
- `Validated`: クラスタvalidationが通っているか
- `RequirementsMet`: 必要Host数、Agent承認、role、validationがそろっているか
- `Completed`: インストール完了か
- `Failed`: 失敗していないか

## Agent Checks

```bash
oc get agent -n <namespace>
oc describe agent <agent-name> -n <namespace>
oc get agent <agent-name> -n <namespace> -o jsonpath='{.status.inventory.hostname}{"\n"}{.status.inventory.interfaces}{"\n"}'
```

Hostをインストール対象にするには、通常 `approved` が必要です。

```bash
oc patch agent <agent-name> -n <namespace> --type merge -p '{"spec":{"approved":true}}'
```

roleやinstallation diskも、環境に応じて明示します。

```bash
oc patch agent <agent-name> -n <namespace> --type merge -p '{"spec":{"role":"master"}}'
oc patch agent <agent-name> -n <namespace> --type merge -p '{"spec":{"installation_disk_id":"/dev/disk/by-id/<disk-id>"}}'
```

## InfraEnv And ISO

```bash
oc get infraenv <name> -n <namespace> -o yaml
oc get infraenv <name> -n <namespace> -o jsonpath='{.status.isoDownloadURL}{"\n"}'
```

ISOが生成されない場合は、pull secret、proxy、SSH key、mirror registry、CA証明書、NMStateConfig selectorを確認します。

## Static Network

静的IPや複数NICを使う場合は、`NMStateConfig` と `InfraEnv.spec.nmStateConfigLabelSelector` の対応を確認します。

```bash
oc get nmstateconfig -n <namespace>
oc describe nmstateconfig <name> -n <namespace>
oc get infraenv <name> -n <namespace> -o jsonpath='{.spec.nmStateConfigLabelSelector}{"\n"}'
```

## Common Failure Patterns

- Hostが `Agent` として登録されない
- `Agent` はいるが `Connected` や `Validated` が通らない
- `Agent.spec.approved` がfalseのまま
- `AgentClusterInstall` の必要Host数に達していない
- `ClusterImageSet` のrelease imageをpullできない
- disconnected環境でmirror registryまたはCA証明書が足りない
- static networkのMACアドレス、interface名、gateway、DNSが実機と合わない
- BMH連携時に `BareMetalHost` と `Agent` のMAC対応が取れていない

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Assisted Service Hive integration: https://github.com/openshift/assisted-service/blob/master/docs/hive-integration/README.md
- Assisted Installer repository: https://github.com/openshift/assisted-installer
- Assisted Service repository: https://github.com/openshift/assisted-service
- Red Hat Advanced Cluster Management documentation: https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes

## Related

- [[20-architecture/assisted-installer-hive-integration|Assisted Installer Hive Integration]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[20-architecture/operators|Operators]]
