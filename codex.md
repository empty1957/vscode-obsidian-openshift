# Codex Daily Knowledge Workflow

このリポジトリは、OpenShift とクラウドネイティブ技術のナレッジベースです。
Codex は GitHub リポジトリ `empty1957/vscode-obsidian-openshift` と連携し、日次で小さく、検証可能な改善を提案します。

## Daily Goal

毎日 1 つのテーマに絞り、実務で使える知識を増やします。

対象領域:

- OpenShift
- Kubernetes
- CNCF ecosystem
- Service Mesh
- Observability
- GitOps
- Platform Engineering
- DevSecOps
- Cloud Native Security
- SRE
- FinOps
- IaC
- CI/CD

## Workflow

1. `docs/` 配下の既存ノートを読み、薄いノート、未整理メモ、リンク切れ、重複、文字化けを探します。
2. その日に深めるテーマを 1 つだけ選びます。
3. 既存ノートの補強を優先し、必要な場合だけ新規ノートを作成します。
4. 変更には、概要、重要性、主要概念、実務での使いどころ、サンプル、関連技術、参考リンクを含めます。
5. 破壊的な構成変更や大量リネームは行いません。
6. 変更後に Markdown と MkDocs の構造を確認します。
7. GitHub には Pull Request として提案します。

## Writing Rules

- 1 回の変更は 1 テーマに集中します。
- 既存記事と重複する説明は避けます。
- 初学者向けの説明と実務者向けの観点を両方含めます。
- 可能な限り YAML、CLI、アーキテクチャ例を含めます。
- 判断や設計理由は `docs/80-decisions/` に残します。
- 参考リンクは末尾に追加します。
- 公式ドキュメントや一次情報を優先します。
- 出典が確認できない事実は断定しません。
- ブランド、人物、企業、法律、価格、バージョンなど変化しうる情報は、必ず最新情報を確認してから書きます。

## GitHub Rules

- 直接 `main` に反映せず、Pull Request で提案します。
- PR タイトルは、変更対象と学習価値が分かるものにします。
- PR 本文には以下を含めます。
  - 今日深めたテーマ
  - 変更したノート
  - 追加した実務ポイント
  - 確認したコマンドまたは未確認事項
- 既に開いている PR がある場合は、内容を確認してから、新規 PR にするか既存 PR を更新するか判断します。

## Quality Bar

- 実務に使えない雑談や創作は入れません。
- 事実、手順、判断理由を分けて書きます。
- `[[path/to/note|Label]]` 形式の Wiki リンクを維持します。
- 文字化けを見つけた場合は、内容を推測で復元せず、分かる範囲で明確な日本語に直します。
