# Glossary

OpenShift、Kubernetes、CKA、CKAD、CKSレベルの用語集です。短く引けることを優先し、詳細は関連ノートへリンクします。

## Core Kubernetes

- **API Server**: Kubernetes APIの入口。すべての操作は最終的にAPI Serverへ送られます。
- **Cluster**: Control PlaneとWorker Nodeで構成されるKubernetes実行基盤です。
- **Control Plane**: API Server、etcd、Scheduler、Controller Managerなど、クラスタ全体を制御するコンポーネント群です。
- **Node**: Podを実行するサーバまたは仮想マシンです。
- **Worker Node**: アプリケーションPodを実行するNodeです。
- **kubelet**: Node上でPodの起動、停止、状態報告を行うエージェントです。
- **kube-proxy**: Serviceの仮想IPやNodePort通信を実現するコンポーネントです。
- **etcd**: クラスタ状態を保存する分散Key-Value Storeです。
- **Scheduler**: Pending状態のPodをどのNodeへ配置するか決めるコンポーネントです。
- **Controller Manager**: 宣言された状態と実際の状態を一致させる制御ループ群です。
- **Reconciliation**: 望ましい状態へ実際の状態を収束させる考え方です。
- **Object**: Pod、Service、Deploymentなど、Kubernetes APIで管理されるリソースです。
- **Resource**: APIで作成、取得、更新、削除できる管理対象です。
- **Manifest**: KubernetesリソースをYAMLやJSONで定義したファイルです。
- **Namespace**: リソースを論理的に分離する単位です。
- **Label**: リソースへ付与するKey-Valueメタデータです。
- **Selector**: Labelに基づいて対象リソースを選ぶ条件です。
- **Annotation**: ツールやコントローラ向けの追加メタデータです。
- **OwnerReference**: あるリソースが別リソースに所有されている関係を示します。
- **Finalizer**: 削除前に外部リソース解放などの処理を完了させる仕組みです。
- **Garbage Collection**: 所有者が消えたリソースを自動削除する仕組みです。

## Workloads

- **Pod**: 1つ以上のコンテナをまとめたKubernetesの最小実行単位です。
- **Container**: イメージから起動されるプロセス隔離単位です。
- **Init Container**: アプリケーションコンテナ起動前に順番に実行されるコンテナです。
- **Sidecar**: メインアプリケーションを補助する同居コンテナです。
- **Static Pod**: kubeletが直接管理し、API Server経由で作成されないPodです。
- **ReplicaSet**: 指定数のPodレプリカを維持するリソースです。
- **Deployment**: ReplicaSetを管理し、ローリング更新やロールバックを提供します。
- **StatefulSet**: 安定したPod名、順序、永続ストレージを持つワークロードです。
- **DaemonSet**: 各NodeにPodを1つずつ配置する用途のワークロードです。
- **Job**: 完了するまで実行される一回限りの処理です。
- **CronJob**: スケジュールに従ってJobを作成するリソースです。
- **Rolling Update**: Podを段階的に入れ替える更新方式です。
- **Rollback**: 以前のReplicaSetや設定へ戻す操作です。
- **Probe**: コンテナの状態を確認する仕組みです。
- **Liveness Probe**: コンテナを再起動すべきか判断するProbeです。
- **Readiness Probe**: Serviceの転送先に含めるべきか判断するProbeです。
- **Startup Probe**: 起動に時間がかかるアプリケーション向けのProbeです。
- **Resource Requests**: スケジューリング時に必要量として扱われるCPU/メモリ指定です。
- **Resource Limits**: コンテナが利用できるCPU/メモリ上限です。
- **QoS Class**: RequestsとLimitsの指定に応じたPodの品質クラスです。
- **HPA**: Horizontal Pod Autoscaler。メトリクスに応じてPod数を増減します。
- **VPA**: Vertical Pod Autoscaler。PodのCPU/メモリ推奨値や設定を調整します。
- **PDB**: PodDisruptionBudget。メンテナンス時に同時停止できるPod数を制御します。
- **Taint**: Nodeへ付与し、許容しないPodを配置させない制約です。
- **Toleration**: Podが特定のTaintを許容する設定です。
- **Affinity**: Podを特定条件のNodeやPod近くへ配置するルールです。
- **Anti-Affinity**: Podを特定条件から離して配置するルールです。
- **Topology Spread Constraint**: ZoneやNodeなどのトポロジにPodを分散する制約です。

## Networking

- **Service**: Podへの安定したアクセス先を提供するリソースです。
- **ClusterIP**: クラスタ内部向けService IPです。
- **NodePort**: 各NodeのポートでServiceを公開する方式です。
- **LoadBalancer**: 外部LoadBalancerと連携するService種別です。
- **Headless Service**: ClusterIPを持たず、Pod DNSを直接返すServiceです。
- **Endpoint**: Serviceの実際の転送先Pod IPとPortです。
- **EndpointSlice**: Endpointをスケーラブルに分割管理するリソースです。
- **Ingress**: HTTP/HTTPSルーティングを定義するKubernetesリソースです。
- **Ingress Controller**: Ingress定義を実際のプロキシ設定へ反映するコンポーネントです。
- **Route**: OpenShift固有の外部HTTP/HTTPS公開リソースです。
- **DNS**: Service名やPod名を名前解決する仕組みです。
- **CoreDNS**: Kubernetesで一般的に使われるDNSサーバです。
- **CNI**: Container Network Interface。Podネットワークを設定するプラグイン仕様です。
- **Multus**: Podに複数ネットワークインターフェースを付与するCNIメタプラグインです。
- **NetworkAttachmentDefinition**: Multusで追加ネットワークを定義するリソースです。
- **NetworkPolicy**: Pod間や外部との通信を制御するリソースです。
- **Egress**: Podから外へ出る通信です。
- **Ingress Traffic**: PodやServiceへ入る通信です。
- **MTU**: ネットワークで一度に送れる最大パケットサイズです。
- **NAT**: IPアドレスを変換して通信する仕組みです。
- **OVN-Kubernetes**: OpenShiftで利用されるPodネットワーク実装の一つです。
- **SDN**: Software Defined Networking。ソフトウェアで制御するネットワークです。
- **MetalLB**: bare metal環境でLoadBalancer Serviceを提供する実装です。
- **BGP**: 経路情報を交換するためのルーティングプロトコルです。
- **L2 Advertisement**: MetalLBが同一L2セグメントへService IPを広告する方式です。
- **SR-IOV**: 物理NICを複数の仮想機能に分割し、高性能ネットワークをPodなどへ提供する技術です。
- **PF**: Physical Function。SR-IOV対応NICの物理機能です。
- **VF**: Virtual Function。PodやVMに割り当てる仮想NIC機能です。
- **NMState**: Linuxネットワーク設定を宣言的に管理する仕組みです。

## Storage

- **Volume**: Podへマウントされるストレージ定義です。
- **PersistentVolume**: クラスタに存在する永続ストレージ実体です。
- **PersistentVolumeClaim**: アプリケーションが要求する永続ストレージです。
- **StorageClass**: 動的プロビジョニング方式やパラメータを定義します。
- **Dynamic Provisioning**: PVCに応じてPVを自動作成する仕組みです。
- **Access Mode**: RWO、ROX、RWXなど、PVのマウント方法を示します。
- **RWO**: ReadWriteOnce。単一Nodeから読み書き可能です。
- **RWX**: ReadWriteMany。複数Nodeから読み書き可能です。
- **CSI**: Container Storage Interface。ストレージプラグインの標準仕様です。
- **CSI Driver**: CSI仕様に従いストレージ操作を実装するコンポーネントです。
- **Storage Snapshot**: PVCの時点コピーです。
- **Reclaim Policy**: PVC削除後にPVを削除するか保持するかのポリシーです。
- **emptyDir**: Pod存続中だけ使える一時領域です。
- **hostPath**: Node上のパスをPodへ直接マウントするVolumeです。強い権限を伴います。
- **ConfigMap Volume**: ConfigMapをファイルとしてPodへ渡す方式です。
- **Secret Volume**: SecretをファイルとしてPodへ渡す方式です。

## Configuration

- **ConfigMap**: 非機密の設定値を保持するリソースです。
- **Secret**: パスワード、トークン、証明書などを保持するリソースです。
- **Environment Variable**: コンテナに渡す環境変数です。
- **Downward API**: Podやコンテナ自身のメタデータを環境変数やファイルで渡す仕組みです。
- **ServiceAccount**: PodやプロセスがKubernetes APIへアクセスするためのIDです。
- **ImagePullSecret**: private registryからイメージをpullするための認証情報です。
- **Immutable ConfigMap/Secret**: 作成後に変更できない設定リソースです。

## Security

- **RBAC**: Role Based Access Control。API操作権限を制御する仕組みです。
- **Role**: Namespace内の権限セットです。
- **ClusterRole**: クラスタスコープまたは複数Namespaceで使える権限セットです。
- **RoleBinding**: RoleやClusterRoleをUser、Group、ServiceAccountへ割り当てます。
- **ClusterRoleBinding**: ClusterRoleをクラスタスコープで割り当てます。
- **Subject**: 権限付与の対象となるUser、Group、ServiceAccountです。
- **Verb**: get、list、watch、create、update、deleteなどのAPI操作です。
- **Authentication**: 利用者やプロセスが誰かを確認する仕組みです。
- **Authorization**: 認証済み主体に操作を許可するか判断する仕組みです。
- **Admission Controller**: APIリクエストを永続化前に検査、変更、拒否する仕組みです。
- **Mutating Admission Webhook**: APIリクエスト内容を変更するWebhookです。
- **Validating Admission Webhook**: APIリクエストを検証し拒否できるWebhookです。
- **SecurityContext**: PodやコンテナのLinux権限、UID、Capabilitiesなどを指定します。
- **Pod Security Admission**: Podのセキュリティ水準をNamespace単位で制御する仕組みです。
- **Pod Security Standards**: privileged、baseline、restrictedのPodセキュリティ基準です。
- **SCC**: Security Context Constraints。OpenShift固有のPod実行制約です。
- **SELinux**: Linuxの強制アクセス制御です。
- **Seccomp**: コンテナが利用できるsystem callを制限する仕組みです。
- **AppArmor**: Linux Security Moduleの一つでプロセス権限を制御します。
- **Linux Capabilities**: root権限を細かく分割した権限単位です。
- **Privileged Container**: Hostに近い強い権限を持つコンテナです。
- **runAsNonRoot**: root以外のUIDでコンテナを実行させる設定です。
- **readOnlyRootFilesystem**: root filesystemを書き込み不可にする設定です。
- **Supply Chain Security**: イメージ、依存関係、ビルド、署名、配布経路を守る考え方です。
- **Image Scanning**: コンテナイメージの脆弱性を検査することです。
- **Image Signing**: イメージの作成元や改ざん有無を検証できるよう署名することです。
- **SBOM**: Software Bill of Materials。ソフトウェア部品表です。
- **OPA**: Open Policy Agent。ポリシーをコードとして評価する仕組みです。
- **Gatekeeper**: OPAをKubernetes admissionに統合するプロジェクトです。
- **Kyverno**: Kubernetes向けポリシーエンジンです。
- **Audit Log**: API操作や認証認可の記録です。
- **Secret Rotation**: Secretを定期的または必要時に更新する運用です。

## Operations

- **`oc`**: OpenShift CLIです。
- **`kubectl`**: Kubernetes CLIです。
- **kubeconfig**: クラスタ接続先、認証情報、contextを持つ設定ファイルです。
- **Context**: CLIが操作するクラスタ、ユーザー、Namespaceの組み合わせです。
- **Event**: リソースで起きた状態変化や警告の記録です。
- **Log**: コンテナ、Node、Operatorなどが出力する実行記録です。
- **Metrics**: CPU、メモリ、リクエスト数などの数値時系列データです。
- **Alert**: 条件に基づき通知される異常や注意です。
- **Prometheus**: メトリクス収集とアラート評価の仕組みです。
- **Alertmanager**: Prometheus Alertを通知先へルーティングするコンポーネントです。
- **Grafana**: メトリクスなどを可視化するダッシュボードツールです。
- **Loki**: ログ保存、検索向けのログ集約システムです。
- **Vector**: ログやイベントを収集、変換、転送するエージェントです。
- **ClusterLogForwarder**: OpenShift Loggingでログ転送pipelineを定義するリソースです。
- **Operator**: 運用ロジックをKubernetes controllerとして実装したものです。
- **CRD**: Custom Resource Definition。独自APIリソースを追加する仕組みです。
- **Custom Resource**: CRDによって定義された独自リソースです。
- **OLM**: Operator Lifecycle Manager。Operatorの導入、更新、管理を行います。
- **Subscription**: OLMでOperatorの更新チャネルや導入元を指定するリソースです。
- **CatalogSource**: Operatorカタログの取得元です。
- **InstallPlan**: Operator導入や更新の具体的な実行計画です。
- **ClusterOperator**: OpenShift基盤Operatorの状態を表すリソースです。
- **ClusterVersion**: OpenShiftクラスタのバージョンと更新状態を表すリソースです。
- **Drain**: NodeからPodを退避させ、メンテナンス可能にする操作です。
- **Cordon**: Nodeへ新しいPodをスケジュールさせない操作です。
- **Uncordon**: Cordonを解除する操作です。
- **Backup**: 障害や誤操作に備えてデータや設定を保存することです。
- **Restore**: バックアップから状態を復旧することです。
- **RPO**: Recovery Point Objective。許容されるデータ損失時間です。
- **RTO**: Recovery Time Objective。復旧までに許容される時間です。
- **Upgrade**: クラスタやコンポーネントを新バージョンへ更新することです。
- **Disconnected Environment**: インターネットへ直接出られない制限環境です。
- **Mirror Registry**: disconnected環境で必要イメージを保持する内部registryです。

## OpenShift Specific

- **OpenShift**: Kubernetesを基盤に、開発、運用、セキュリティ機能を統合したプラットフォームです。
- **Project**: OpenShiftでの作業単位です。Kubernetes Namespaceに対応します。
- **BuildConfig**: OpenShiftのビルド設定リソースです。
- **ImageStream**: イメージタグの参照と更新を管理するOpenShiftリソースです。
- **DeploymentConfig**: OpenShift独自の古いデプロイリソースです。新規ではDeploymentを優先します。
- **Source-to-Image**: ソースコードからコンテナイメージを作成する仕組みです。
- **OpenShift Router**: Routeを処理するIngress Controller実装です。
- **Console**: OpenShiftのWeb UIです。
- **MachineConfig**: Node OS設定を宣言するOpenShiftリソースです。
- **MachineConfigPool**: MachineConfigの適用対象Node集合です。
- **Machine API**: NodeとなるMachineのライフサイクルを管理する仕組みです。
- **Assisted Installer**: bare metalやedge環境でOpenShiftインストールを支援する仕組みです。
- **Discovery ISO**: Assisted Installerでホストを検出するために起動するISOです。
- **API VIP**: OpenShift APIの仮想IPです。
- **Ingress VIP**: Router/Ingressへ到達するための仮想IPです。
- **OpenShift Logging**: OpenShift上のログ収集、転送、保存、検索の仕組みです。
- **OpenShift Virtualization**: KubeVirtを基盤にVMをOpenShift上で実行する機能です。
- **Data Foundation**: OpenShift向けのソフトウェア定義ストレージ製品です。
- **GitOps**: Gitを望ましい状態の正としてクラスタへ反映する運用です。
- **Pipelines**: Tektonを基盤とするOpenShiftのCI/CD機能です。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- OpenShift CLI documentation: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/cli_tools/openshift-cli-oc
- kubectl command reference: https://kubernetes.io/docs/reference/kubectl/

## Related

- [[10-overview/openshift-overview|OpenShift Overview]]
- [[20-architecture/metallb-operator|MetalLB Operator]]
- [[20-architecture/sriov-network-operator|SR-IOV Network Operator]]
- [[20-architecture/nmstate-operator|NMState Operator]]
- [[30-operations/assisted-installer|Assisted Installer]]
- [[30-operations/openstack-logging|OpenStack Logging]]

