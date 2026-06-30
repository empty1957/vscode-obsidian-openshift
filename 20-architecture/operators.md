# Operators

OperatorはKubernetes上でアプリケーションや基盤コンポーネントの運用知識を自動化する仕組みです。

## Concepts

- Custom Resource: 利用者が宣言する目的の状態
- Controller: Custom Resourceを監視して実際の状態を調整
- Operator Lifecycle Manager: Operatorの導入、更新、管理

## Notes

- Operatorの更新チャネルを確認します。
- CRDのバージョンと互換性を確認します。
- 自動更新の影響範囲を事前に判断します。

## Related

- [[30-operations/upgrade-runbook|Upgrade Runbook]]
- [[80-decisions/_index|Decisions]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/assisted-installer|Assisted Installer]]
- [[30-operations/openstack-logging|OpenStack Logging]]
