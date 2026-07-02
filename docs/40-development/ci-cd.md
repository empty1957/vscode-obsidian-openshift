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

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Workloads: https://kubernetes.io/docs/concepts/workloads/
- Kubernetes ConfigMaps: https://kubernetes.io/docs/concepts/configuration/configmap/
- Kubernetes Secrets: https://kubernetes.io/docs/concepts/configuration/secret/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/_index|Security]]

