# OpenShift Knowledge Base

VS Code の Foam 拡張機能と MkDocs で扱う OpenShift ナレッジベースです。

このリポジトリは、OpenShift / Kubernetes の学習、設計、運用、開発、セキュリティ、トラブルシュートを短く参照できるように整理したものです。まずは [[10-overview/_index|Overview]] から読み始めます。新しいメモは [[00-inbox/_index|Inbox]] に置き、整理できたら該当カテゴリへ移動します。

## Repository Layout

| Path | 内容 | 主な根拠 |
| --- | --- | --- |
| `docs/10-overview` | OpenShift全体像、学習ロードマップ、最初に読む入口 | Red Hat OpenShift Documentation、Kubernetes Concepts |
| `docs/20-architecture` | クラスタ構成、Operator、Networking、Storage、Assisted Installerなどの設計知識 | Red Hat OpenShift Documentation、Operator Framework、各Operatorの元リポジトリ |
| `docs/30-operations` | 日常運用、ヘルスチェック、バックアップ、アップグレード、Operator導入Runbook | Red Hat OpenShift Documentation、Kubernetes Debugging、運用系公式手順 |
| `docs/40-development` | アプリケーション配置、CI/CD、ConfigMap/Secretなど開発者向け知識 | Kubernetes Workloads、Kubernetes Tasks、OpenShift Developer向け機能 |
| `docs/50-security` | RBAC、SCC、NetworkPolicy、Secret管理などのセキュリティ知識 | Kubernetes Security、OpenShift Security and compliance |
| `docs/60-troubleshooting` | ImagePullBackOff、CrashLoopBackOff、Route疎通不可などの切り分け | Kubernetes Debugging、OpenShift CLI確認観点 |
| `docs/70-reference` | 用語集、CLIチートシート、外部リンク、元リポジトリ一覧 | Red Hat / Kubernetes / Operator Framework公式リンク、GitHubリポジトリ |
| `docs/80-decisions` | ナレッジベース構成や重要判断のADR | Markdown / ADR運用、リポジトリ内の設計判断 |
| `docs/90-templates` | ノート、Runbook、ADR、Troubleshootingのテンプレート | このリポジトリの粒度ルール |

## Main Maps

- [[10-overview/_index|Overview]]
- [[20-architecture/_index|Architecture]]
- [[30-operations/_index|Operations]]
- [[40-development/_index|Development]]
- [[50-security/_index|Security]]
- [[60-troubleshooting/_index|Troubleshooting]]
- [[70-reference/_index|Reference]]
- [[80-decisions/_index|Decisions]]
- [[90-templates/_index|Templates]]

## Focus Topics

- [[20-architecture/operators|Operators]]
- [[20-architecture/operator-cli-installation|Operator CLI Installation]]
- [[20-architecture/assisted-installer-hive-integration|Assisted Installer Hive Integration]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[30-operations/assisted-installer|Assisted Installer Operations]]
- [[30-operations/openstack-logging|OpenStack Logging]]

## Writing Rules

- 1トピック1ファイルを基本にします。
- 各ノートは「概要」「主要概念または確認手順」「設計/運用ポイント」「Sources」「Related」の粒度に寄せます。
- Architecture系は、役割、主要リソース、処理の流れ、設計ポイント、障害パターンを中心にします。
- Operations系は、前提、確認コマンド、判断基準、よくある失敗、次に見るノートを中心にします。
- Troubleshooting系は、症状、確認コマンド、よくある原因、次アクションを中心にします。
- 関連ノートは `[[10-overview/openshift-overview]]` のようなWikiリンク形式でリンクします。
- コマンドや手順には、対象バージョン、前提条件、確認方法を残します。
- 外部情報に基づく内容は、各Markdownの `Sources` に公式ドキュメントまたは元リポジトリを埋め込みます。
- 判断や設計理由は [[80-decisions/_index|Decisions]] に残します。

## Source Policy

ナレッジの一次情報は、原則として次を優先します。

1. Red Hat OpenShift / RHACM / OpenShift Logging 公式ドキュメント
2. Kubernetes公式ドキュメント
3. Operator Framework / Operator SDK公式ドキュメント
4. OpenShift、Kubernetes、Operator、MetalLB、NMStateなどの元リポジトリ
5. このリポジトリ内のADR、Runbook、検証メモ

公式ドキュメントと実装リポジトリの対応は [[70-reference/external-links|External Links]] と [[70-reference/repositories|Repositories]] に集約しています。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Red Hat Advanced Cluster Management Documentation: https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes
- Kubernetes Documentation: https://kubernetes.io/docs/
- Operator Framework Documentation: https://olm.operatorframework.io/docs/
- MkDocs Documentation: https://www.mkdocs.org/
- Material for MkDocs Documentation: https://squidfunk.github.io/mkdocs-material/

## GitHub Pages

`main` ブランチに push すると、GitHub Actions が MkDocs サイトをビルドし、公開用の `gh-pages` ブランチへ反映します。

公開先:

https://empty1957.github.io/vscode-obsidian-openshift/

GitHub 側では、リポジトリの **Settings > Pages > Build and deployment** で Source を **Deploy from a branch** に設定し、Branch を **gh-pages**、Folder を **/(root)** に設定します。
