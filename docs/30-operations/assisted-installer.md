# Assisted Installer

Assisted Installerは、OpenShiftクラスタのインストールを支援する仕組みです。特にbare metal、edge、remote site、restricted networkなど、手作業の前提確認が多い環境で、ホスト検出、事前検証、インストール進行管理を助けます。

## Components

- Assisted Service: クラスタ定義、ホスト情報、validation、install workflowを管理するサービス
- Assisted Installer: 対象ホスト上でインストール処理を実行するコンポーネント
- Discovery ISO: ホストを起動し、Assisted Serviceへinventoryを送るためのISO
- Agent: ホスト情報収集、接続、インストール処理を担うエージェント

## Code Level Flow

Assisted Installerは、OperatorHubで導入する通常のDay 2 Operatorとは異なり、OpenShiftクラスタを作る前後のインストール状態をAPIとAgentで管理します。

1. ユーザーがAssisted Serviceへcluster definitionを作成します。cluster name、base domain、OpenShift version、pull secret、network、VIP、host requirementsなどが保存されます。
2. Assisted ServiceはDiscovery ISOを生成します。ISOにはrendezvous先、pull secret、SSH key、network設定などが埋め込まれます。
3. HostがDiscovery ISOで起動するとAgentがAssisted Serviceへinventoryを送ります。CPU、memory、disk、NIC、MAC、IP、boot mode、platform情報などが含まれます。
4. Assisted Serviceのvalidation engineがclusterとhostの条件を評価します。DNS、NTP、network connectivity、disk size、CPU/memory、role assignmentなどの結果がstatusに反映されます。
5. install開始時にAssisted Serviceが各Hostへ役割と手順を配布します。
6. Assisted Installerがhost上で ignition、bootkube、machine config、kubelet起動、control plane join、worker joinに関係する処理を進めます。
7. 各Host Agentがprogress eventとlogsをAssisted Serviceへ送り、UI/APIにinstalling、installed、errorなどの状態が表示されます。
8. cluster APIが利用可能になると、通常の `oc get clusterversion`、`oc get co`、`oc get nodes` で状態確認できる段階に移ります。

コードの見方としては、Assisted Service側はcluster/host state machineとvalidation、Assisted Installer側はhost上でのinstall step実行、Agent側はinventory収集とイベント送信、という責務分離で追うと理解しやすいです。

## Operations: GUI

1. Hybrid Cloud ConsoleまたはAssisted Installer UIでクラスタ作成を開始します。
2. OpenShift version、cluster name、base domain、pull secret、SSH keyを入力します。
3. Networking画面でDHCP/static、machine network、API VIP、Ingress VIPを設定します。
4. Discovery ISOを生成して各Hostを起動します。
5. Host inventoryとvalidation resultを確認します。
6. Host roleをcontrol planeまたはworkerへ割り当てます。
7. すべてのrequired validationが通ったらInstallを開始します。
8. Events、host progress、logsを見ながら完了を確認します。

## Operations: CLI/API

Assisted Installerは環境により `aicli`、Assisted Service API、Agent-based Installer、またはRed Hat Hybrid Cloud ConsoleのAPIを使います。ここでは確認観点を中心にします。

```bash
oc get nodes
oc get clusterversion
oc get co
oc get pods -A | grep -v Running
```

Agent-based Installerを使う場合は、`install-config.yaml`、`agent-config.yaml`、ISO生成、Host起動、install wait-for completeという流れで扱います。

```bash
openshift-install agent create image
openshift-install agent wait-for bootstrap-complete
openshift-install agent wait-for install-complete
```

## Related Resources

- Cluster definition: Assisted Serviceが管理するクラスタ単位の設定です。
- Host inventory: 各Hostから収集されたハードウェアとネットワーク情報です。
- Validation result: install可能性を判定するチェック結果です。
- Discovery ISO: Agent起動とinventory送信のためのISOです。
- Agent events: Hostごとの進行状況やエラーです。
- `install-config.yaml`: OpenShiftインストール設定です。
- `agent-config.yaml`: Agent-based InstallerのHost、role、rendezvous IPなどを定義します。
- `ClusterVersion`: インストール後のクラスタバージョン状態です。
- `ClusterOperator`: インストール後のOpenShift基盤Operator状態です。

## Operational Flow

1. クラスタ名、base domain、OpenShift version、pull secret、SSH keyを準備します。
2. bare metal hosts、network、VIP、install configを定義します。
3. Discovery ISOでホストを起動します。
4. CPU、memory、disk、network、DNS、NTPなどのvalidationを確認します。
5. 必要な修正を行い、installを開始します。
6. Bootstrap、control plane、worker joinの進行を確認します。

## Design Points

- API VIPとIngress VIPの配置を事前に決めます。
- DHCPかstatic networkかを明確にします。
- disconnected環境ではmirror registryとImageContentSourcePolicy関連を準備します。
- NTP、DNS、reverse DNS、default gatewayは失敗原因になりやすいです。
- Day 2でNodeを追加する場合も、同じネットワーク前提を再確認します。

## Basic Checks

```bash
oc get nodes
oc get clusterversion
oc get co
oc get events -A --sort-by=.lastTimestamp
```

Assisted Service側では、host inventory、validation result、installation events、agent logsを確認します。

## Repositories

- Assisted Installer: https://github.com/openshift/assisted-installer
- Assisted Service: https://github.com/openshift/assisted-service

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[70-reference/repositories|Repositories]]
