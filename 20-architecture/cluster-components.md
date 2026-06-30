# Cluster Components

OpenShiftクラスタを構成する主要コンポーネントの整理です。

## Control Plane

- API Server: Kubernetes/OpenShift APIの入口
- etcd: クラスタ状態を保存する分散KVS
- Scheduler: Podを実行するNodeを決定
- Controller Manager: 宣言された状態へ収束させる制御ループ

## Worker Nodes

- kubelet: Node上のPodを管理
- CRI-O: コンテナランタイム
- SDN/OVN-Kubernetes: Podネットワーク

## OpenShift Specific

- Route/Ingress Controller
- Image Registry
- Operator Lifecycle Manager
- Monitoring Stack
- Console

## Related

- [[20-architecture/networking|Networking]]
- [[20-architecture/operators|Operators]]
- [[30-operations/cluster-health-check|Cluster Health Check]]

