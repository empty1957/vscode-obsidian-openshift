# OpenShift Knowledge Base

VS Code の Foam 拡張機能で扱う OpenShift ナレッジベースです。

まずは [[10-overview/_index|Overview]] から読み始めます。新しいメモは [[00-inbox/_index|Inbox]] に置き、整理できたら該当カテゴリへ移動します。

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

- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[30-operations/assisted-installer|Assisted Installer]]
- [[30-operations/openstack-logging|OpenStack Logging]]

## Writing Rules

- 1トピック1ファイルを基本にします。
- 関連ノートは `[[10-overview/openshift-overview]]` のようなWikiリンク形式でリンクします。
- コマンドや手順には、対象バージョン、前提条件、確認方法を残します。
- 判断や設計理由は [[80-decisions/_index|Decisions]] に残します。

## GitHub Pages

`main` ブランチに push すると、GitHub Actions が MkDocs サイトをビルドし、公開用の `gh-pages` ブランチへ反映します。

公開先:

https://empty1957.github.io/vscode-obsidian-openshift/

GitHub 側では、リポジトリの **Settings > Pages > Build and deployment** で Source を **Deploy from a branch** に設定し、Branch を **gh-pages**、Folder を **/(root)** に設定します。

ローカルで確認する場合:

```bash
pip install -r requirements.txt
mkdocs serve
```
