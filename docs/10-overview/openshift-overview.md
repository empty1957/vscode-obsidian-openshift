# OpenShift Overview

OpenShiftはKubernetesを基盤に、開発者体験、運用管理、セキュリティ、イメージビルド、ルーティングなどを統合したコンテナプラットフォームです。

## Key Concepts

- Kubernetes APIを中心にリソースを宣言的に管理します。
- ProjectはKubernetes Namespaceをユーザー向けに扱いやすくした単位です。
- Routeによりクラスタ外部からアプリケーションへHTTP/HTTPSアクセスできます。
- Operatorによりアプリケーションやミドルウェアのライフサイクルを管理します。
- SCCやRBACにより実行権限と操作権限を制御します。

## Links

- [[20-architecture/cluster-components|Cluster Components]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/rbac-and-scc|RBAC and SCC]]

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Concepts: https://kubernetes.io/docs/concepts/
