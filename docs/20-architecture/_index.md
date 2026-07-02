# Architecture

OpenShiftの構成要素、設計パターン、クラスタ機能を支えるOperatorを整理します。

## Notes

- [[20-architecture/cluster-components|Cluster Components]]
- [[20-architecture/networking|Networking]]
- [[20-architecture/storage|Storage]]
- [[20-architecture/operators|Operators]]
- [[20-architecture/operator-cli-installation|Operator CLI Installation]]
- [[20-architecture/assisted-installer-hive-integration|Assisted Installer Hive Integration]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]

## Operator Knowledge

- Cluster OperatorはOpenShift本体を構成し、Cluster Version Operatorがリリースペイロードに基づいて管理します。
- OperatorHubのAdd-on OperatorはOLMの `Subscription`、`InstallPlan`、`ClusterServiceVersion`、`CustomResourceDefinition` を通じて導入、更新、削除します。
- RHACM/MCE環境のAssisted Installerは、Hive連携のKubernetes APIとして `ClusterDeployment`、`AgentClusterInstall`、`InfraEnv`、`Agent` などを扱います。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/

## Related

- [[50-security/_index|Security]]
- [[30-operations/_index|Operations]]
- [[70-reference/repositories|Repositories]]
