# NMState Operator

NMState Operatorは、Nodeのネットワーク設定をKubernetes APIから宣言的に管理するためのOperatorです。Linux bridge、bond、VLAN、OVS bridge、static route、DNSなど、Podネットワークの前提となるNode側ネットワークを管理します。

## Core Resources

- `NodeNetworkState`: Nodeの現在のネットワーク状態を報告します。
- `NodeNetworkConfigurationPolicy`: 望ましいNodeネットワーク設定を宣言します。
- `NodeNetworkConfigurationEnactment`: Policyの適用状況をNode単位で表します。

## Typical Use Cases

- OpenShift Virtualization向けのLinux bridge作成
- SR-IOVやMultusで使う補助ネットワークの下準備
- bondとVLANを組み合わせた冗長ネットワーク
- 静的IP、route、DNSの標準化
- bare metal環境でのDay 2ネットワーク設定

## Design Points

- Nodeの管理ネットワークを壊す設定はクラスタ到達性を失うため、適用範囲を小さく始めます。
- `nodeSelector` で対象Nodeを限定します。
- `desiredState` は既存状態との差分ではなく、意図する状態として管理します。
- 適用後は `NodeNetworkConfigurationEnactment` の状態を確認します。

## Basic Checks

```bash
oc get nns
oc get nncp
oc get nnce
oc describe nncp <policy-name>
oc describe nnce <policy-name>.<node-name>
```

## Failure Patterns

- 既存インターフェース名がNode間で異なる
- bridge/bond/VLANの親子関係が誤っている
- default routeやDNSを誤って変更する
- NetworkManagerの状態とPolicyの意図が衝突する

## Repository

- Kubernetes NMState: https://github.com/nmstate/kubernetes-nmstate

## Related

- [[20-architecture/networking|Networking]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[70-reference/repositories|Repositories]]

