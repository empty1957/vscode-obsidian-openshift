# NMState Operator

NMState Operatorは、Nodeのネットワーク設定をKubernetes APIから宣言的に管理するためのOperatorです。Linux bridge、bond、VLAN、OVS bridge、static route、DNSなど、Podネットワークの前提となるNode側ネットワークを管理します。

## Core Resources

- `NodeNetworkState`: Nodeの現在のネットワーク状態を報告します。
- `NodeNetworkConfigurationPolicy`: 望ましいNodeネットワーク設定を宣言します。
- `NodeNetworkConfigurationEnactment`: Policyの適用状況をNode単位で表します。

## Code Level Flow

NMState Operatorは、Kubernetes API上のPolicyとNode上のNetworkManager/nmstate実装をつなぐcontrollerです。

1. Operator controllerが `NodeNetworkConfigurationPolicy` をwatchします。
2. Node側のhandler/daemonが現在のNetworkManager状態を取得し、`NodeNetworkState` としてAPIへ報告します。
3. `NodeNetworkConfigurationPolicy.spec.desiredState` が作成または更新されると、controllerは対象Nodeを `nodeSelector` で決定します。
4. 対象Nodeごとに `NodeNetworkConfigurationEnactment` が作られ、Policy適用の進行、成功、失敗理由が記録されます。
5. Node側のdaemonがdesiredStateをnmstate形式として適用し、bridge、bond、VLAN、route、DNSなどをNetworkManagerへ反映します。
6. 適用後の状態が再収集され、`NodeNetworkState.status.currentState` と `NodeNetworkConfigurationEnactment.status` が更新されます。

この流れでは、`NodeNetworkConfigurationPolicy` が入力、`NodeNetworkConfigurationEnactment` が実行結果、`NodeNetworkState` が観測結果です。トラブル時はこの3つの差分を見ます。

## Installation: GUI

1. Consoleで `Operators` -> `OperatorHub` を開きます。
2. `Kubernetes NMState Operator` または `NMState Operator` を検索します。
3. Install namespaceとchannelを確認してInstallします。
4. `Installed Operators` でCSVが `Succeeded` になることを確認します。
5. `Provided APIs` から `NMState` または必要なインスタンスを作成します。
6. `NodeNetworkState` が作られ、Nodeの現在状態が見えることを確認します。
7. `NodeNetworkConfigurationPolicy` を小さな対象Nodeから適用します。

## Installation: CLI

```bash
oc get packagemanifest -n openshift-marketplace | grep -i nmstate
oc get csv -n openshift-nmstate
oc get pods -n openshift-nmstate
oc get crd | grep -i nmstate
```

Policy例です。

```yaml
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
  name: br-external
spec:
  nodeSelector:
    node-role.kubernetes.io/worker: ""
  desiredState:
    interfaces:
      - name: br-external
        type: linux-bridge
        state: up
        bridge:
          options:
            stp:
              enabled: false
          port:
            - name: ens6
```

状態確認です。

```bash
oc get nns
oc get nncp
oc get nnce
oc describe nnce br-external.<node-name>
```

## Related Resources

- `NMState`: Operatorのインスタンス作成に使われるリソースです。
- `NodeNetworkState`: 現在のNodeネットワーク状態です。
- `NodeNetworkConfigurationPolicy`: 望ましいNodeネットワーク設定です。
- `NodeNetworkConfigurationEnactment`: Node単位のPolicy適用結果です。
- `NetworkManager`: Node上で実際に接続プロファイルを管理します。
- `MachineConfigPool`: Node設定変更の影響確認で参照することがあります。

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

- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/networking|Networking]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[70-reference/repositories|Repositories]]
