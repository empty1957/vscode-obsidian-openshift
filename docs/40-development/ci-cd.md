# CI CD

OpenShift向けCI/CDの整理です。

## Patterns

- OpenShift Pipelines
- GitHub Actionsから`oc` CLIで適用
- Argo CDなどのGitOps
- Tektonベースのパイプライン

## Design Questions

- デプロイの承認フローは必要か
- イメージ署名や脆弱性スキャンは必要か
- 環境差分はHelm、Kustomize、別リポジトリのどれで管理するか
- ロールバック手順は明文化されているか

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/_index|Security]]

