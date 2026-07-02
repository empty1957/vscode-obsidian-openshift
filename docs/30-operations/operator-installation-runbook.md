# Operator Installation Runbook

OpenShiftでOperatorを導入するときの共通手順です。OperatorHubのGUI操作と、OLMリソースを直接作成するCLI操作を分けて整理します。

## Related OLM Resources

- `CatalogSource`: Operatorカタログの取得元です。Red Hat公式、Certified、Community、独自ミラーなどがあります。
- `PackageManifest`: CatalogSourceから解決されたOperatorパッケージ情報です。利用可能なchannelやdefault channelを確認できます。
- `OperatorGroup`: Operatorが監視するNamespace範囲を定義します。Namespace単位導入では対象Namespaceに必要です。
- `Subscription`: 導入するOperator、channel、CatalogSource、installPlanApprovalを指定します。
- `InstallPlan`: Subscriptionから生成される具体的な導入または更新計画です。
- `ClusterServiceVersion`: CSVとも呼ばれ、Operatorのバージョン、権限、Deployment、所有CRD、説明を表します。
- `CustomResourceDefinition`: Operatorが提供する独自APIです。
- `Custom Resource`: Operatorに目的状態を伝える実体です。例: `MetalLB`、`SriovNetworkNodePolicy`、`NodeNetworkConfigurationPolicy`。

## GUI: OperatorHub

1. OpenShift Consoleにcluster-admin相当の権限でログインします。
2. `Operators` -> `OperatorHub` を開きます。
3. Operator名で検索します。
4. Provider、install mode、available channel、versionを確認します。
5. `Install` を選びます。
6. `Update channel`、`Installation mode`、`Installed Namespace`、`Update approval` を選びます。
7. `Install` を実行します。
8. `Operators` -> `Installed Operators` でStatusが `Succeeded` になることを確認します。
9. Operator詳細画面の `Provided APIs` から必要なCustom Resourceを作成します。

## CLI: OLM Resources

Operator名、channel、CatalogSource、Namespaceを確認します。

CLI導入で作成するOLMリソースの意味や、`Subscription`、`OperatorGroup`、`InstallPlan` の設計観点は [[20-architecture/operator-cli-installation|Operator CLI Installation]] にまとめています。

```bash
oc get packagemanifest -n openshift-marketplace | grep -i <operator-name>
oc get packagemanifest <package-name> -n openshift-marketplace -o yaml
```

Namespaceを作成します。

```bash
oc create namespace <operator-namespace>
```

NamespaceスコープのOperatorでは `OperatorGroup` を作成します。

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: <operator-group-name>
  namespace: <operator-namespace>
spec:
  targetNamespaces:
    - <operator-namespace>
```

`Subscription` を作成します。

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: <subscription-name>
  namespace: <operator-namespace>
spec:
  channel: <channel>
  installPlanApproval: Automatic
  name: <package-name>
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

導入状態を確認します。

```bash
oc get subscription -n <operator-namespace>
oc get installplan -n <operator-namespace>
oc get csv -n <operator-namespace>
oc get crd | grep -i <operator-keyword>
oc get pods -n <operator-namespace>
```

## Manual Approval

`installPlanApproval: Manual` の場合、InstallPlanを承認するまで導入や更新は進みません。

```bash
oc get installplan -n <operator-namespace>
oc patch installplan <installplan-name> -n <operator-namespace> --type merge -p '{"spec":{"approved":true}}'
```

## Post Installation

- Operator PodがRunningか確認します。
- CSVが `Succeeded` か確認します。
- CRDが作成されているか確認します。
- 最小構成のCustom Resourceを作成します。
- Operatorログにreconcile errorがないか確認します。
- RBAC、SCC、Webhook、DaemonSetなど、Operatorが作った関連リソースを把握します。

## Common Commands

```bash
oc describe csv <csv-name> -n <operator-namespace>
oc logs deploy/<operator-deployment> -n <operator-namespace>
oc get events -n <operator-namespace> --sort-by=.lastTimestamp
oc api-resources | grep -i <operator-keyword>
```

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/

## Related

- [[20-architecture/operators|Operators]]
- [[20-architecture/operator-cli-installation|Operator CLI Installation]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/openstack-logging|OpenStack Logging]]

