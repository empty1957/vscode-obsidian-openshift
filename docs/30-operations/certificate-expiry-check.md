# Certificate Expiry Check

OpenShiftクラスタ内の証明書期限を確認し、期限切れリスクを早期に検知するRunbookです。

## Purpose

API Server、Ingress、kubelet、OAuth、内部サービス証明書などの期限切れによる障害を避けるため、定期点検で証明書状態を確認します。

## Preconditions

- `cluster-admin` 相当の権限があること。
- クラスタの通常ヘルスチェックが完了していること。
- 証明書更新作業をする場合は、変更時間帯と影響範囲を確保すること。

## Steps

1. ClusterOperatorの証明書関連劣化を確認します。

```bash
oc get co
oc get co authentication kube-apiserver openshift-apiserver ingress
```

2. 証明書関連Secretを確認します。

```bash
oc get secret -A | grep -i cert
oc get secret -n openshift-config
oc get secret -n openshift-ingress
```

3. Ingress証明書を確認します。

```bash
oc get ingresscontroller -n openshift-ingress-operator
oc describe ingresscontroller default -n openshift-ingress-operator
```

4. API疎通と認証を確認します。

```bash
oc whoami
oc get clusterversion
oc get apiservices | grep -v True
```

5. 期限切れや更新失敗が疑われる場合は、関連Operatorのconditionsとeventsを確認します。

```bash
oc describe co authentication
oc describe co kube-apiserver
oc get events -A --sort-by=.lastTimestamp
```

## Rollback

確認のみならRollbackは不要です。証明書Secretを変更した場合は、変更前のSecret名、namespace、内容、適用時刻を記録し、公式手順に従って元の証明書へ戻します。

## Verification

```bash
oc get co
oc get clusterversion
oc login --server=<api-url>
```

認証、API、Ingress関連Operatorが `Available=True` かつ `Degraded=False` であることを確認します。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Certificates: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
- OpenShift Security and compliance: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance

## Related

- [[30-operations/cluster-health-check|Cluster Health Check]]
- [[50-security/secrets-management|Secrets Management]]
- [[50-security/rbac-and-scc|RBAC and SCC]]
