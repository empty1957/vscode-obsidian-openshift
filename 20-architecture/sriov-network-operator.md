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

## Related

- [[20-architecture/networking|Networking]]
- [[50-security/rbac-and-scc|RBAC and SCC]]
- [[70-reference/repositories|Repositories]]

