# Operators

OperatorはKubernetes API上でアプリケーションや基盤コンポーネントの運用知識を自動化する仕組みです。OpenShiftでは、クラスタ本体を構成するCluster Operatorと、OperatorHub/OLMで導入するAdd-on Operatorを分けて理解すると整理しやすくなります。

## Big Picture

| 区分 | 管理主体 | 代表例 | ユーザー操作 |
| --- | --- | --- | --- |
| Cluster Operator | Cluster Version Operator | API Server、etcd、Ingress、DNS、Network、Monitoring、Machine Config、Console | 原則として個別に削除・更新しません。クラスタ更新に従います。 |
| Red Hat Add-on Operator | OLM | Pipelines、GitOps、Service Mesh、ODF、Logging、OpenShift AI、Virtualization | `Subscription`、`InstallPlan`、CSV、CRで導入・更新します。 |
| Certified Operator | OLM | ISV製DB、監視、セキュリティ、バックアップ、ネットワーク製品 | サポート範囲、channel、権限を確認して導入します。 |
| Community Operator | OLM | コミュニティ提供OSS Operator | サポート性と更新方針を個別に確認します。 |
| Custom Operator | OLMまたは独自管理 | 社内アプリ、独自運用自動化、業務基盤 | Operator SDK、Helm、Ansible、Goなどで実装します。 |

## Core Concepts

- Custom Resource: 利用者が宣言する目的状態です。
- Controller: Custom Resourceを監視し、実際の状態を目的状態へ近づけます。
- Reconcile Loop: 差分検出、作成、更新、削除、status反映を繰り返す制御ループです。
- Operator Lifecycle Manager: Operatorの導入、更新、依存関係、CSV、InstallPlanを管理します。
- Cluster Version Operator: OpenShiftリリースペイロードを基準にCluster Operator群を管理します。

## Cluster Operators

Cluster OperatorはOpenShiftクラスタ本体を構成・維持します。`oc get clusteroperators` または `oc get co` で状態を確認します。

| Operator | 主な役割 |
| --- | --- |
| Cluster Version Operator | OpenShiftリリースペイロードに基づき、Cluster Operator群とクラスタ更新を管理します。 |
| Machine Config Operator | RHCOS、kubelet、MachineConfigPool、ノード再起動を伴う設定を管理します。 |
| Cluster Network Operator | OVN-Kubernetesなどのクラスタネットワークを管理します。 |
| Ingress Operator | RouterとIngressControllerを管理します。 |
| DNS Operator | CoreDNSとクラスタ内名前解決を管理します。 |
| Cluster Monitoring Operator | Prometheusベースの監視スタックを管理します。 |
| Cluster Storage Operator | CSIドライバ、StorageClass、スナップショット関連の基盤を管理します。 |
| Machine API Operator | Machine、MachineSet、MachineHealthCheckを管理します。 |
| Cloud Credential Operator | クラウド認証情報を管理します。 |
| Authentication / OAuth関連Operator | 認証、OAuth、Consoleログイン体験を支えます。 |

## Add-on Operator Categories

`一覧.txt` の分類を、設計時に使いやすいカテゴリとして整理します。

| カテゴリ | 代表Operator | 設計観点 |
| --- | --- | --- |
| Networking | NMState、SR-IOV、MetalLB、External DNS、Network Observability | Nodeネットワーク、LoadBalancer、追加NIC、外部DNS、通信可視化 |
| Security / Compliance | Compliance、File Integrity、Security Profiles、cert-manager、External Secrets | 監査、証明書、Secret連携、Nodeセキュリティ |
| Storage / Data Protection | OpenShift Data Foundation、Local Storage、LVMS、OADP、Migration Toolkit | 永続ストレージ、バックアップ、リストア、移行 |
| Observability / Logging / Tracing | Logging、Loki、OpenTelemetry、Tempo、Power Monitoring | ログ保存、メトリクス、トレース、運用可視化 |
| CI/CD / Developer Platform | Pipelines、GitOps、Builds、Web Terminal、Dev Spaces、Serverless | 開発者体験、GitOps、ビルド、サーバーレス |
| Service Mesh / Integration | Service Mesh、Kiali、AMQ Streams、AMQ Broker、3scale、Service Binding | 東西トラフィック制御、API管理、メッセージング |
| Virtualization / Windows / VM | OpenShift Virtualization、HostPath Provisioner、Windows Machine Config、MTV | VM実行、Windowsノード、VM移行 |
| AI / ML / Accelerator | NVIDIA GPU、AMD GPU、Node Feature Discovery、KMM、Kueue、OpenShift AI | GPU、アクセラレータ、AI基盤、分散ジョブ |
| Multi-cluster / Management | RHACM、multicluster engine、Topology Aware Lifecycle Manager、Policy系 | Hub/Spoke管理、クラスタライフサイクル、Policy適用 |

## OLM Resource Flow

OperatorHubでInstallを押す操作は、OLMのリソース作成と状態遷移として見ることができます。

1. `CatalogSource` から利用可能なOperatorカタログを取得します。
2. `PackageManifest` でpackage名、channel、CSVを確認します。
3. 導入先namespaceに `OperatorGroup` を作成し、監視範囲を定義します。
4. `Subscription` でpackage、channel、CatalogSource、承認方式を指定します。
5. OLMが `InstallPlan` を生成します。
6. `installPlanApproval: Manual` の場合は、管理者がInstallPlanを承認します。
7. OLMがCSV、Deployment、RBAC、CRDなどを作成します。
8. CSVが `Succeeded` になると、Operator固有のCustom Resourceを作成できる状態になります。

詳細なCLI手順は [[20-architecture/operator-cli-installation|Operator CLI Installation]] にまとめています。

## Design Points

- Cluster OperatorとAdd-on Operatorを混同しないようにします。
- Add-on Operatorは導入前にpackage名、channel、install mode、namespace、必要権限、CRDを確認します。
- 本番環境では `installPlanApproval: Manual` を使うと、更新タイミングを制御しやすくなります。
- disconnected環境ではCatalogSource、ImageContentSourcePolicy/ImageDigestMirrorSet、pull secret、証明書を合わせて設計します。
- Operatorが作るRBAC、Webhook、DaemonSet、SCC、CRDは障害時の確認対象です。
- Custom Resourceの作成はOperator導入完了後に行います。CSVが失敗している状態でCRだけ作ってもreconcileされません。

## Basic Checks

Cluster Operatorの確認です。

```bash
oc get clusteroperators
oc get co
oc describe clusteroperator <name>
```

OLM管理Operatorの確認です。

```bash
oc get catalogsource -n openshift-marketplace
oc get packagemanifest -n openshift-marketplace
oc get subscriptions -A
oc get installplan -A
oc get csv -A
oc get operatorgroup -A
oc get crd | grep <keyword>
```

## Related

- [[20-architecture/operator-cli-installation|Operator CLI Installation]]
- [[20-architecture/assisted-installer-hive-integration|Assisted Installer Hive Integration]]
- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/openstack-logging|OpenStack Logging]]
