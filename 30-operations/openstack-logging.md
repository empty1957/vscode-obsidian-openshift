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

- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[50-security/secrets-management|Secrets Management]]
- [[70-reference/repositories|Repositories]]

