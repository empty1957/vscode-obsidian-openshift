# MetalLB Operator

MetalLB Operatorは、ベアメタルやオンプレミスなどクラウドLoadBalancerがない環境で、Kubernetes Service `type: LoadBalancer` を使えるようにするためのOperatorです。

## What It Solves

- OpenShift on bare metalで外部向けのLoadBalancer IPを払い出します。
- L2広告またはBGPにより、サービスIPへの到達経路をネットワークへ伝えます。
- IngressController、API公開、アプリケーション公開などで外部IPを安定的に扱えます。

## Main Resources

- `MetalLB`: Operatorが管理するMetalLBインスタンス
- `IPAddressPool`: 払い出し可能なLoadBalancer IP範囲
- `L2Advertisement`: L2モードでアドバタイズするIPプール
- `BGPPeer`: BGPピア設定
- `BGPAdvertisement`: BGPで広告するIPプールと属性

## Design Points

- L2モードはシンプルですが、同一L2セグメント内での利用が前提です。
- BGPモードはネットワーク装置との連携が必要ですが、より大きなネットワーク設計に向きます。
- `IPAddressPool` はクラスタ外のDHCP範囲や他システムのIPと重複させません。
- 複数ネットワークや複数ラックをまたぐ場合は、障害ドメインと経路制御を明確にします。

## Operations

```bash
oc get metallb -A
oc get ipaddresspool -A
oc get l2advertisement -A
oc get bgppeer -A
oc get svc -A | grep LoadBalancer
```

## Failure Patterns

- `EXTERNAL-IP` が `pending` のままになる
- IPプールが枯渇している
- L2到達性またはBGPピアリングが成立していない
- firewallやACLでService IPへの通信が遮断されている

## Repositories

- OpenShift MetalLB Operator: https://github.com/openshift/metallb-operator
- MetalLB upstream: https://github.com/metallb/metallb

## Related

- [[20-architecture/networking|Networking]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]
- [[70-reference/repositories|Repositories]]

