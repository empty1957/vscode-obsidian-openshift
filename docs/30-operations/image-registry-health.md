# Image Registry Health

OpenShift内部Image Registryの状態を確認するRunbookです。

## Purpose

ビルド、デプロイ、ImageStream利用でイメージpush/pullに失敗する場合に、内部registry、storage、route、Operator状態を切り分けます。

## Preconditions

- `cluster-admin` または `openshift-image-registry` namespaceを確認できる権限があること。
- 失敗しているbuild、deployment、image pullのエラー内容を取得していること。

## Steps

1. Image Registry Operatorの状態を確認します。

```bash
oc get co image-registry
oc describe co image-registry
```

2. Registry設定を確認します。

```bash
oc get configs.imageregistry.operator.openshift.io cluster -o yaml
```

3. Registry PodとServiceを確認します。

```bash
oc get pods -n openshift-image-registry
oc get svc -n openshift-image-registry
oc logs deploy/image-registry -n openshift-image-registry --tail=100
```

4. Storage設定とPVCを確認します。

```bash
oc get pvc -n openshift-image-registry
oc describe pvc -n openshift-image-registry
```

5. ImageStreamとイベントを確認します。

```bash
oc get imagestream -A
oc get events -A --sort-by=.lastTimestamp | grep -i image
```

## Rollback

確認のみならRollbackは不要です。registry設定を変更した場合は、変更前の `configs.imageregistry.operator.openshift.io/cluster` を保存し、問題時に元のspecへ戻します。

## Verification

```bash
oc get co image-registry
oc get pods -n openshift-image-registry
oc new-build --binary --name registry-check -n <test-project>
```

Registry Operatorが安定し、push/pullまたはbuildが成功することを確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Images: https://kubernetes.io/docs/concepts/containers/images/
- OpenShift Image Registry documentation: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/registry

## Related

- [[60-troubleshooting/imagepullbackoff|ImagePullBackOff]]
- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[30-operations/cluster-health-check|Cluster Health Check]]
