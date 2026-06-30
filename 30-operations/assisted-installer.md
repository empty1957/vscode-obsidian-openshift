# Assisted Installer

Assisted Installerは、OpenShiftクラスタのインストールを支援する仕組みです。特にbare metal、edge、remote site、restricted networkなど、手作業の前提確認が多い環境で、ホスト検出、事前検証、インストール進行管理を助けます。

## Components

- Assisted Service: クラスタ定義、ホスト情報、validation、install workflowを管理するサービス
- Assisted Installer: 対象ホスト上でインストール処理を実行するコンポーネント
- Discovery ISO: ホストを起動し、Assisted Serviceへinventoryを送るためのISO
- Agent: ホスト情報収集、接続、インストール処理を担うエージェント

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
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[70-reference/repositories|Repositories]]

