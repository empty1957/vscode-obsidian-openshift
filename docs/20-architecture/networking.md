# Networking

OpenShiftにおけるネットワークの整理です。

## Main Layers

- Pod Network: Pod同士の通信
- Service: Podへの安定した仮想IP
- Route: クラスタ外部からHTTP/HTTPSで公開
- Ingress Controller: Route/Ingressの入口
- NetworkPolicy: NamespaceやPod間通信の制御

## Checkpoints

- ServiceのselectorがPod labelと一致しているか
- RouteのhostとTLS設定が正しいか
- NetworkPolicyで必要な通信が許可されているか
- DNS解決ができるか

## Related

- [[50-security/network-policy|Network Policy]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
