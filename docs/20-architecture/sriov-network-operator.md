# SR-IOV Network Operator

SR-IOV Network Operatorは、SR-IOV対応NICをOpenShift上のPodへ割り当てるためのOperatorです。高スループット、低遅延、CPUオーバーヘッド削減が必要なCNF、NFV、通信、HPC、AI/ML、ストレージネットワークで使います。

## Core Concepts

- PF: Physical Function。物理NICの管理側機能
- VF: Virtual Function。PodやVMへ割り当てる仮想NIC機能
- `SriovNetworkNodePolicy`: Node上のPFからVFを作成し、resourceNameを定義します。
- `SriovNetwork`: Podが利用するSR-IOVネットワークを定義します。
- `SriovNetworkNodeState`: NodeごとのNIC検出結果と適用状態を確認します。
- NetworkAttachmentDefinition: Multus経由でPodへ追加NICを渡します。

## Architecture

SR-IOV Network Operatorは、Operator本体、Webhook、Resource Injector、Config Daemon、Device Plugin、SR-IOV CNIなどで構成されます。Node側のConfig DaemonがNICを検出し、`SriovNetworkNodePolicy` に従ってVFを作成します。

## Code Level Flow

SR-IOV Network Operatorは、Control Plane側のcontrollerとNode側のDaemon群で役割が分かれます。

1. Operator controllerが `SriovNetworkNodePolicy`、`SriovNetwork`、`SriovNetworkNodeState`、`SriovOperatorConfig` などをwatchします。
2. Node上のConfig DaemonがNICをスキャンし、PF名、vendor ID、device ID、driver、numVfsなどを `SriovNetworkNodeState.status.interfaces` に報告します。
3. ユーザーが `SriovNetworkNodePolicy` を作成すると、controllerは対象Node、PF、VF数、deviceType、resourceNameを解釈します。
4. Config Daemonが対象Node上でPFのVF数やdriver bindingを変更します。必要に応じてNode再起動やMCPとの連携が発生します。
5. SR-IOV device pluginがVFをKubernetes拡張リソースとしてkubeletへ登録します。例: `openshift.io/intel_sriov_netdevice`。
6. `SriovNetwork` が作成されると、Operatorは対応する `NetworkAttachmentDefinition` を生成します。
7. PodがMultus annotationとresource requestを指定すると、admission/resource injectorが必要なresource requestを補完し、kubeletが該当VFを割り当てます。
8. SR-IOV CNIがPod network namespaceへVFを接続し、IPAM設定に従ってIPを設定します。

コードの見方としては、CRのwatch、Node stateの収集、policy render、daemonによるhost設定、device plugin登録、NAD生成、Pod admissionの順に追うと理解しやすいです。

## Installation: GUI

1. Consoleで `Operators` -> `OperatorHub` を開きます。
2. `SR-IOV Network Operator` を検索します。
3. install namespaceとして通常は `openshift-sriov-network-operator` を選びます。
4. Install後、CSVが `Succeeded` になることを確認します。
5. `SriovNetworkNodeState` でNIC検出状態を確認します。
6. `SriovNetworkNodePolicy` を作成してVFを構成します。
7. `SriovNetwork` を作成してPodから利用する追加ネットワークを定義します。

## Installation: CLI

```bash
oc create namespace openshift-sriov-network-operator
oc get packagemanifest -n openshift-marketplace | grep -i sriov
oc get csv -n openshift-sriov-network-operator
oc get pods -n openshift-sriov-network-operator
```

検出状態を確認します。

```bash
oc get sriovnetworknodestate -n openshift-sriov-network-operator
oc describe sriovnetworknodestate <node-name> -n openshift-sriov-network-operator
```

Policy例です。

```yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetworkNodePolicy
metadata:
  name: worker-pf0-netdevice
  namespace: openshift-sriov-network-operator
spec:
  nodeSelector:
    feature.node.kubernetes.io/network-sriov.capable: "true"
  resourceName: sriov_pf0
  numVfs: 8
  nicSelector:
    pfNames:
      - ens5f0
  deviceType: netdevice
```

## Related Resources

- `SriovNetworkNodePolicy`: VF数、対象PF、deviceType、resourceNameを定義します。
- `SriovNetworkNodeState`: NodeごとのNIC inventoryと適用状態です。
- `SriovNetwork`: Multus向けネットワークを定義します。
- `NetworkAttachmentDefinition`: Pod annotationから参照される追加ネットワーク定義です。
- `DaemonSet`: Config Daemon、device plugin、CNI関連PodをNodeへ配置します。
- `MachineConfigPool`: NIC設定変更に伴うNode再起動や更新状態の確認で関係します。
- `NodeFeatureDiscovery`: SR-IOV対応Nodeのlabel付与に使われることがあります。

## Design Points

- BIOS、ファームウェア、NICドライバ、IOMMU設定を事前に確認します。
- `nodeSelector` でSR-IOV対応Nodeを明示します。
- `resourceName` はPodのresource requestと一致させます。
- VF数変更はNode再起動やメンテナンス影響を伴う場合があります。
- `netdevice` と `vfio-pci` のどちらを使うかはワークロード要件で判断します。

## Basic Checks

```bash
oc get sriovnetworknodepolicy -n openshift-sriov-network-operator
oc get sriovnetworknodestate -n openshift-sriov-network-operator
oc get sriovnetwork -A
oc get network-attachment-definitions -A
oc describe node <node-name>
```

## Failure Patterns

- 対象NodeでSR-IOV対応NICが検出されない
- PF名やvendor/device IDが一致していない
- VF resourceがPodへ割り当たらない
- NetworkAttachmentDefinitionの参照名がPod annotationと一致しない
- DPDK/RDMA/OVS hardware offloadの前提が満たされていない

## Repository

- OpenShift SR-IOV Network Operator: https://github.com/openshift/sriov-network-operator

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift SR-IOV Network Operator documentation: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/networking_operators/sr-iov-operator
- OpenShift SR-IOV Network Operator repository: https://github.com/openshift/sriov-network-operator

## Related

- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[20-architecture/networking|Networking]]
- [[50-security/rbac-and-scc|RBAC and SCC]]
- [[70-reference/repositories|Repositories]]
