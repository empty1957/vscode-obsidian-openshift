# Assisted Installer Hive Integration

RHACMまたはmulticluster engineのHubクラスタでAssisted Installerを使う場合、設計の中心はGUI単体のインストーラではなく、Hive連携のKubernetes APIです。Hub上のCRDでSpokeクラスタ、Discovery ISO、Host Agent、インストール状態を宣言し、Assisted Serviceがバックエンドとして検証とインストール進行を管理します。

## Positioning

- RHACM/MCEはマルチクラスタ管理とクラスタライフサイクル管理の入口です。
- Hiveは `ClusterDeployment` を通じてクラスタ作成の上位APIを提供します。
- Assisted Installerはbare metal、edge、on-premisesなどのHost検出、事前検証、インストール実行を担います。
- Hive integrationでは、Assisted Installer APIがCRDとしてHubクラスタに現れます。

## Main Resources

| Resource | API group | 役割 |
| --- | --- | --- |
| `ClusterDeployment` | `hive.openshift.io/v1` | 作成するSpokeクラスタの上位定義です。`spec.clusterInstallRef` で `AgentClusterInstall` を参照します。 |
| `AgentClusterInstall` | `extensions.hive.openshift.io/v1beta1` | OpenShiftバージョン、ネットワーク、control plane数、worker数、platform、install config override、状態条件を管理します。 |
| `InfraEnv` | `agent-install.openshift.io/v1beta1` | Discovery ISOの生成単位です。pull secret、SSH key、proxy、NMStateConfig selector、clusterRefなどを持ちます。 |
| `Agent` | `agent-install.openshift.io/v1beta1` | Discovery ISOで起動してHubへ登録されたHostです。inventory、role、approved、installation disk、conditionsを持ちます。 |
| `NMStateConfig` | `agent-install.openshift.io/v1beta1` | static network設定をHostへ渡すためのリソースです。InfraEnvのlabel selectorで関連付けます。 |
| `ClusterImageSet` | `hive.openshift.io/v1` | インストール対象のOpenShift release imageを定義します。 |
| `ManagedCluster` | `cluster.open-cluster-management.io/v1` | RHACM管理対象クラスタとしてのSpoke登録を表します。 |
| `KlusterletAddonConfig` | `agent.open-cluster-management.io/v1` | RHACMのaddon有効化設定です。 |

## Code Level Flow

1. HubクラスタにRHACM/MCE、Hive、Assisted Service関連コンポーネントが用意されます。
2. 管理者が `ClusterImageSet`、pull secret、`ClusterDeployment`、`AgentClusterInstall`、`InfraEnv` を作成します。
3. `InfraEnv` controllerがDiscovery ISOを生成し、`status.isoDownloadURL` などにURLを反映します。
4. Bare metal HostをDiscovery ISOで起動します。Host上のAgentがinventoryをAssisted Serviceへ送信します。
5. Assisted ServiceがHostごとに `Agent` CRを作成し、CPU、memory、disk、NIC、boot mode、validation結果をstatusへ反映します。
6. 管理者または自動化が `Agent.spec.approved: true`、role、hostname、installation diskなどを設定します。
7. `AgentClusterInstall` が必要Host数、Host readiness、cluster validation、Agent approvalを満たすとインストールが開始されます。
8. インストール開始後、`AgentClusterInstall.spec` の重要項目は変更しても反映されにくくなるため、開始前に設計値を固めます。
9. 完了後、`ClusterDeployment` はInstalled状態になり、kubeconfigや管理者認証情報のSecretが参照されます。
10. RHACM側では `ManagedCluster` とaddon設定により、SpokeがHub管理下に入ります。

## Minimal Resource Shape

`ClusterDeployment` は `AgentClusterInstall` を参照します。

```yaml
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: spoke01
  namespace: spoke01
spec:
  baseDomain: example.com
  clusterName: spoke01
  clusterInstallRef:
    group: extensions.hive.openshift.io
    kind: AgentClusterInstall
    name: spoke01
    version: v1beta1
  platform:
    agentBareMetal:
      agentSelector:
        matchLabels:
          cluster-name: spoke01
  pullSecretRef:
    name: pull-secret
```

`AgentClusterInstall` はクラスタのインストール要件を定義します。

```yaml
apiVersion: extensions.hive.openshift.io/v1beta1
kind: AgentClusterInstall
metadata:
  name: spoke01
  namespace: spoke01
spec:
  clusterDeploymentRef:
    name: spoke01
  imageSetRef:
    name: openshift-v4.16.0
  networking:
    clusterNetwork:
      - cidr: 10.128.0.0/14
        hostPrefix: 23
    machineNetwork:
      - cidr: 192.0.2.0/24
    serviceNetwork:
      - 172.30.0.0/16
    networkType: OVNKubernetes
  provisionRequirements:
    controlPlaneAgents: 3
    workerAgents: 2
```

`InfraEnv` はDiscovery ISO生成の入力です。

```yaml
apiVersion: agent-install.openshift.io/v1beta1
kind: InfraEnv
metadata:
  name: spoke01
  namespace: spoke01
spec:
  clusterRef:
    name: spoke01
    namespace: spoke01
  pullSecretRef:
    name: pull-secret
  sshAuthorizedKey: ssh-rsa AAAA...
```

Hostが登録されたら `Agent` を確認し、必要に応じて承認します。

```bash
oc get infraenv -n spoke01
oc get agent -n spoke01
oc patch agent <agent-name> -n spoke01 --type merge -p '{"spec":{"approved":true}}'
```

## Conditions To Watch

```bash
oc get agentclusterinstall -n spoke01
oc get agentclusterinstall spoke01 -n spoke01 -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.message}{"\n"}{end}'
oc get agent -n spoke01
oc get agent -n spoke01 -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.inventory.hostname}{"\t"}{range .status.conditions[*]}{.type}={.status}{" "}{end}{"\n"}{end}'
```

よく見る条件です。

- `SpecSynced`: CRの内容がAssisted Serviceへ反映されているか
- `Validated`: クラスタまたはHostのvalidationが通っているか
- `RequirementsMet`: 必要なHost数、role、approval、validationがそろっているか
- `Completed`: インストールが完了したか
- `Failed`: インストール失敗が発生していないか

## BareMetalHost Integration

Bare Metal OperatorをHubで使う場合、BareMetal Agent Controllerが `BareMetalHost` と `Agent` をMACアドレスで対応付けます。BMHのannotationからrole、hostname、MachineConfigPool、installer args、ignition override、cluster referenceなどがAgentへ反映されます。

OpenShift 4.12以降のHubではconverged flowが基本になり、Preprovisioning Image Controllerが `PreprovisioningImage` と `InfraEnv` を調整します。この場合、Discovery ISOはmetal3連携を前提に生成されるため、boot-it-yourself用途のISOとは扱いが変わります。

## Design Points

- HubとSpokeの役割を分けます。HubはCRDとAssisted Serviceを管理し、Spokeはインストール対象です。
- `ClusterDeployment` と `AgentClusterInstall` のnamespaceをクラスタ単位で分けると、SecretやAgentの見通しが良くなります。
- `ClusterImageSet` はHubとSpokeのアーキテクチャ、disconnected mirror、サポート対象バージョンを合わせます。
- `InfraEnv` と `NMStateConfig` はラベルで関連付くため、静的IP環境ではISO生成前にNMStateConfigをそろえます。
- validation bypassはサポート性を落とすため、最後の手段として扱います。
- インストール開始後に `AgentClusterInstall` の設計値を変えるより、失敗原因を直して再作成する方が明確な場合があります。
- Day 2 worker追加では、既存クラスタに紐づくInfraEnvからHostを起動し、追加Agentを承認します。

## Failure Patterns

- `InfraEnv` のISO URLが生成されない
- pull secret、proxy、mirror registry、CA証明書の設定不足でイメージ取得に失敗する
- `Agent` がConnectedにならない
- Host inventoryが不足し、validationが通らない
- `Agent.spec.approved` がfalseのまま
- `ClusterDeployment.spec.clusterInstallRef` と `AgentClusterInstall` の対応が誤っている
- `NMStateConfig` のMACアドレスやinterface名がHost実体と一致しない
- `ClusterImageSet` のrelease imageがHubまたはSpoke環境からpullできない

## Related

- [[30-operations/assisted-installer|Assisted Installer Operations]]
- [[20-architecture/operators|Operators]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[20-architecture/networking|Networking]]
- [[70-reference/repositories|Repositories]]
