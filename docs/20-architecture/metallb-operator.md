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

## Code Level Flow

MetalLB OperatorはOLMで導入されると、Operator Deploymentとして起動し、MetalLB関連CRDを監視します。中心になる処理はKubernetes Controllerのreconcile loopです。

1. `MetalLB` CRが作成されます。
2. Operatorのcontrollerがwatchイベントを受け、現在のDeployment、DaemonSet、ServiceAccount、RBAC、Webhook、Config関連リソースを読みます。
3. 期待する状態との差分を計算し、MetalLB本体のcontroller/speakerなどのリソースを作成または更新します。
4. `IPAddressPool`、`L2Advertisement`、`BGPPeer`、`BGPAdvertisement` が作成されると、MetalLB本体側のcontrollerがService `type: LoadBalancer` とIPプールを突き合わせます。
5. IPが割り当てられると、Serviceのstatusに `EXTERNAL-IP` が反映されます。
6. speakerがNode上でL2 ARP/NDPまたはBGP広告を行い、外部ネットワークからService IPへ到達できるようにします。

重要なのは、OperatorはMetalLB本体を配置、更新、設定する役割であり、実際のService IP割り当てや経路広告はMetalLB本体のcontroller/speakerが担う点です。

## Installation: GUI

1. Consoleで `Operators` -> `OperatorHub` を開きます。
2. `MetalLB Operator` を検索します。
3. channel、install namespace、approval strategyを確認してInstallします。
4. `Installed Operators` でCSVが `Succeeded` になることを確認します。
5. `Provided APIs` から `MetalLB` CRを作成します。
6. `IPAddressPool` と `L2Advertisement` または `BGPPeer` / `BGPAdvertisement` を作成します。

## Installation: CLI

```bash
oc create namespace metallb-system
oc get packagemanifest -n openshift-marketplace | grep -i metallb
```

`Subscription` と必要に応じて `OperatorGroup` を作成し、CSVを確認します。

```bash
oc get csv -n metallb-system
oc get crd | grep -i metallb
oc get pods -n metallb-system
```

最小構成の例です。

```yaml
apiVersion: metallb.io/v1beta1
kind: MetalLB
metadata:
  name: metallb
  namespace: metallb-system
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: app-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.0.2.100-192.0.2.120
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: app-l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - app-pool
```

## Related Resources

- `Service` `type: LoadBalancer`: MetalLBが外部IPを割り当てる対象です。
- `EndpointSlice`: Serviceの転送先Pod情報です。
- `DaemonSet`: speakerをNodeへ配置します。
- `Deployment`: MetalLB controllerを配置します。
- `Secret`: BGP passwordなどを扱う場合に参照します。
- `ValidatingWebhookConfiguration`: MetalLB CRの検証に使われます。

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

- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/networking|Networking]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]
- [[70-reference/repositories|Repositories]]
