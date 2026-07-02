# OpenStack Logging

OpenStack Loggingは、OpenShift上で稼働するOpenStack関連サービスや基盤コンポーネントのログを、収集、集約、検索、保管、転送するための運用領域です。OpenShiftのLogging subsystem、Cluster Logging Operator、Loki、Vector、ClusterLogForwarderなどと組み合わせて設計します。

## Scope

- OpenStack control planeのPodログ
- OpenStack dataplane関連のログ
- Kubernetes/OpenShiftイベント
- Node、journald、audit、container runtimeログ
- 外部SIEM、object storage、ログ分析基盤への転送

## OpenShift Logging Concepts

- Cluster Logging Operator: logging stackを管理します。
- Vector: ログ収集、変換、転送を担います。
- LokiStack: ログ保存と検索のバックエンドとして利用されます。
- ClusterLogForwarder: ログ転送先、入力、pipelineを宣言します。

## Code Level Flow

OpenShift Loggingでは、Cluster Logging OperatorやLoki OperatorがCRを監視し、collector、gateway、backend、RBAC、Secret参照、Serviceを作成します。OpenStack Loggingとして見る場合も、基本の流れはOpenShift LoggingのCRDとreconcileです。

1. `ClusterLogForwarder` が作成されます。
2. Logging Operatorのcontrollerがinputs、filters、outputs、pipelinesを読み、collector設定を生成します。
3. collectorとしてVectorのDaemonSetまたはDeploymentが配置され、Node上のcontainer log、journald、audit logなどを読みます。
4. Vectorはpipeline定義に従ってログをparse、filter、transformし、Loki、Kafka、syslog、HTTP、CloudWatchなどのoutputへ転送します。
5. Lokiを使う場合、`LokiStack` をLoki Operatorが監視し、distributor、ingester、querier、query-frontend、gatewayなどを配置します。
6. OpenStack serviceのPodログは、namespace、pod、container、labelなどのmetadata付きで収集されます。
7. 管理者はLog UI、Loki query、外部転送先、または保存先object storageでログを検索します。

コードレベルでは、`ClusterLogForwarder` はログ収集の宣言、Vector設定は実行時設定、`LokiStack` は保存/検索基盤の宣言です。reconcile errorが出る場合、CRのstatus conditionsとOperatorログを一緒に見ます。

## Installation: GUI

1. Consoleで `Operators` -> `OperatorHub` を開きます。
2. `Red Hat OpenShift Logging` を検索してInstallします。
3. Lokiを使う場合は `Loki Operator` もInstallします。
4. `Installed Operators` でCSVが `Succeeded` になることを確認します。
5. `LokiStack` を作成します。
6. `ClusterLogForwarder` を作成し、application、infrastructure、auditなどのinputとoutputを定義します。
7. `openshift-logging` namespaceのcollector PodがRunningになることを確認します。

## Installation: CLI

```bash
oc create namespace openshift-logging
oc get packagemanifest -n openshift-marketplace | grep -i logging
oc get packagemanifest -n openshift-marketplace | grep -i loki
oc get csv -n openshift-logging
oc get pods -n openshift-logging
```

ClusterLogForwarderの例です。

```yaml
apiVersion: observability.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  outputs:
    - name: default-loki
      type: lokiStack
      lokiStack:
        target:
          name: logging-loki
          namespace: openshift-logging
      authentication:
        token:
          from: serviceAccount
  pipelines:
    - name: openstack-app-logs
      inputRefs:
        - application
      outputRefs:
        - default-loki
```

## Related Resources

- `ClusterLogForwarder`: ログinput、filter、output、pipelineを宣言します。
- `LokiStack`: Lokiの保存、検索、gateway構成を宣言します。
- `ServiceAccount`: collectorやgatewayがAPIやLokiへアクセスするIDです。
- `Secret`: 外部転送先の認証情報やTLS証明書を保持します。
- `DaemonSet`: Nodeごとのログcollectorを配置します。
- `PodMonitor` / `ServiceMonitor`: logging stackのメトリクス収集に使われます。
- `ObjectBucketClaim`: Lokiのobject storageを動的に確保する構成で使われます。

## Design Points

- OpenStack serviceごとのnamespaceとlabel設計をログ検索軸に合わせます。
- 保存期間、圧縮、転送先、個人情報や認証情報のマスキング方針を決めます。
- 障害時に必要なログを、Pod再作成後も追えるようにします。
- control planeとdataplaneの時刻同期を確認します。
- Lokiを使う場合は、label cardinalityを増やしすぎないようにします。

## Basic Checks

```bash
oc get pods -n openshift-logging
oc get clusterlogforwarder -A
oc get lokistack -A
oc logs -n openshift-logging deploy/cluster-logging-operator
oc adm node-logs <node-name>
```

## Failure Patterns

- ログが転送先に届かない
- pipeline selectorが対象ログを拾っていない
- Lokiの保存容量やretentionが不足している
- label cardinalityが高すぎて検索や保存が重い
- OpenStack serviceのPod名変更で検索条件が壊れる

## Repository

- Cluster Logging Operator: https://github.com/openshift/cluster-logging-operator

## Related

- [[30-operations/operator-installation-runbook|Operator Installation Runbook]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[50-security/secrets-management|Secrets Management]]
- [[70-reference/repositories|Repositories]]
