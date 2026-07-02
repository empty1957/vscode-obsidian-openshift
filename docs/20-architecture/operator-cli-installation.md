# Operator CLI Installation

OpenShiftでCLIからOperatorを導入するときは、Operator Lifecycle Managerのリソースを直接作成します。ConsoleのOperatorHubで行う操作は、内部的には `Namespace`、`OperatorGroup`、`Subscription`、`InstallPlan`、`ClusterServiceVersion`、`CustomResourceDefinition` の管理に対応します。

## When To Use CLI

- GitOpsや変更管理にOperator導入手順を残したい場合
- disconnected環境や閉域環境でCatalogSourceを明示したい場合
- RHACM Policy、Argo CD、CIからOperator導入を自動化したい場合
- InstallPlanの承認タイミングを人手で制御したい場合

## Resource Model

| Resource | 役割 |
| --- | --- |
| `CatalogSource` | Operatorカタログの取得元です。標準では `openshift-marketplace` namespaceの `redhat-operators` などを使います。 |
| `PackageManifest` | カタログから解決されたOperatorパッケージ情報です。利用可能なchannel、default channel、install mode確認に使います。 |
| `Namespace` | Operatorをインストールするnamespaceです。Operatorごとに推奨namespaceが決まっていることがあります。 |
| `OperatorGroup` | Operatorが監視するnamespace範囲を定義します。namespaceスコープ導入では対象namespaceに1つ必要です。 |
| `Subscription` | どのpackageを、どのchannelから、どのCatalogSourceで購読するかを定義します。 |
| `InstallPlan` | Subscriptionから生成される実際のインストールまたは更新計画です。Manual承認時はここを承認します。 |
| `ClusterServiceVersion` | CSV。Operatorのバージョン、Deployment、権限、所有CRD、導入状態を表します。 |
| `CustomResourceDefinition` | Operatorが提供するAPIです。導入後にCRを作る前提になります。 |
| `Custom Resource` | 利用者がOperatorに渡す目的状態です。例: `MetalLB`、`NMState`、`SriovNetworkNodePolicy`。 |

## 1. Package And Channel

まず、Operatorパッケージ名とchannelを確認します。

```bash
oc get packagemanifest -n openshift-marketplace | grep -i <keyword>
oc get packagemanifest <package-name> -n openshift-marketplace -o yaml
```

確認する観点です。

- `status.catalogSource`: 利用するCatalogSource名
- `status.catalogSourceNamespace`: 通常は `openshift-marketplace`
- `status.defaultChannel`: 既定channel
- `status.channels[].name`: 選択可能なchannel
- `status.channels[].currentCSV`: channel上の現在CSV

## 2. Namespace

Operatorの推奨namespaceを作ります。Red Hat提供Operatorは、製品ごとに固定namespaceが推奨されることがあります。

```bash
oc create namespace <operator-namespace>
```

例です。

```bash
oc create namespace metallb-system
oc create namespace openshift-nmstate
oc create namespace openshift-sriov-network-operator
```

## 3. OperatorGroup

namespaceスコープで導入する場合は `OperatorGroup` を作ります。

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

クラスタ全体を監視するOperatorでは、Operatorのドキュメントに従って `targetNamespaces` を省略することがあります。1つのnamespaceに複数のOperatorGroupを置くとCSVが失敗しやすいため、既存の有無を先に確認します。

```bash
oc get operatorgroup -n <operator-namespace>
```

## 4. Subscription

`Subscription` はCLI導入の中心です。`name` にはpackage名、`source` にはCatalogSource名、`channel` には購読するchannelを指定します。

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

`installPlanApproval` の考え方です。

- `Automatic`: InstallPlanが自動承認され、導入や更新が進みます。
- `Manual`: InstallPlanを明示的に承認するまで導入や更新が止まります。本番環境や変更管理が厳しい環境向けです。

## 5. Apply Example

ファイルとして管理する場合の例です。

```bash
oc apply -f operatorgroup.yaml
oc apply -f subscription.yaml
```

インラインで一度だけ作る場合の例です。

```bash
oc apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: example-operator-group
  namespace: example-operator
spec:
  targetNamespaces:
    - example-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: example-operator
  namespace: example-operator
spec:
  channel: stable
  installPlanApproval: Manual
  name: example-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

## 6. InstallPlan Approval

Manual承認では、InstallPlanを確認してから承認します。

```bash
oc get installplan -n <operator-namespace>
oc describe installplan <installplan-name> -n <operator-namespace>
oc patch installplan <installplan-name> -n <operator-namespace> --type merge -p '{"spec":{"approved":true}}'
```

確認する観点です。

- どのCSVへ更新されるか
- 追加または更新されるCRD
- 作成されるServiceAccount、ClusterRole、RoleBinding
- 対象namespaceと権限範囲

## 7. Verify Installation

```bash
oc get subscription -n <operator-namespace>
oc get installplan -n <operator-namespace>
oc get csv -n <operator-namespace>
oc get pods -n <operator-namespace>
oc get crd | grep -i <operator-keyword>
oc describe csv <csv-name> -n <operator-namespace>
```

CSVが `Succeeded` になり、Operator PodがRunningになり、必要なCRDが作成されていればOperator導入は完了です。その後、Operator固有のCustom Resourceを作成します。

## 8. Minimal Examples

### MetalLB Operator

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: metallb-operator-group
  namespace: metallb-system
spec:
  targetNamespaces:
    - metallb-system
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: metallb-operator
  namespace: metallb-system
spec:
  channel: stable
  installPlanApproval: Automatic
  name: metallb-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

### Kubernetes NMState Operator

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-nmstate
  namespace: openshift-nmstate
spec:
  targetNamespaces:
    - openshift-nmstate
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kubernetes-nmstate-operator
  namespace: openshift-nmstate
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kubernetes-nmstate-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

### SR-IOV Network Operator

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: sriov-network-operators
  namespace: openshift-sriov-network-operator
spec:
  targetNamespaces:
    - openshift-sriov-network-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: sriov-network-operator-subscription
  namespace: openshift-sriov-network-operator
spec:
  channel: stable
  installPlanApproval: Automatic
  name: sriov-network-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

## Common Failure Points

- package名とSubscription名を混同している
- channelが存在しない、またはクラスタバージョンに対応していない
- OperatorGroupがない、または同じnamespaceに複数ある
- disconnected環境でCatalogSourceやイメージミラーが未設定
- Manual承認のInstallPlanが未承認
- CSVが必要とするCRDや権限を作成できていない

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift Operators: https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/operators/understanding-operators
- Operator Lifecycle Manager documentation: https://olm.operatorframework.io/docs/
- Operator Framework repositories: https://github.com/operator-framework

## Related

- [[20-architecture/operators|Operators]]
- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
