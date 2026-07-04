# Network Policy

Namespace 内外の Pod 通信を、アプリケーション単位で明示的に許可するための設計メモです。
OpenShift では `NetworkPolicy` を使い、選択した Pod に対する ingress / egress の許可ルールを定義します。

## 判断ポイント

- まず Namespace 単位で default deny を入れるかを決めます。
- アプリケーションが本当に必要とする通信だけを、Pod label / Namespace label / port で許可します。
- egress を絞る場合は、DNS、監視、ログ転送、外部 API への通信を事前に洗い出します。
- 既存環境では、最初に検証 Namespace で適用し、疎通確認とアプリログ確認をしてから本番へ反映します。

## 基本パターン

### Namespace の ingress を既定拒否にする

同じ Namespace 内の Pod も含め、明示的に許可していない着信を拒否します。

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app-prod
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

### フロントエンドから API への通信だけを許可する

`role=frontend` の Pod から `role=api` の Pod の TCP 8080 だけを許可します。

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: app-prod
spec:
  podSelector:
    matchLabels:
      role: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### egress を既定拒否にした後で DNS を許可する

default deny egress は DNS も止めます。名前解決が必要な Pod には、クラスタ DNS への UDP/TCP 53 を明示的に許可します。

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: app-prod
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: openshift-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

クラスタや CNI の実装差で DNS Pod の Namespace / label が異なる可能性があります。適用前に次のように確認します。

```bash
oc get ns --show-labels | grep -E 'openshift-dns|kube-system'
oc get pod -n openshift-dns --show-labels
oc get svc -n openshift-dns
```

## 確認コマンド

```bash
oc get networkpolicy -n app-prod
oc describe networkpolicy -n app-prod allow-frontend-to-api
oc get pod -n app-prod --show-labels
oc exec -n app-prod deploy/frontend -- curl -sS http://api:8080/healthz
oc exec -n app-prod deploy/frontend -- nslookup kubernetes.default.svc
```

通信が失敗した場合は、まず selector が期待した Pod / Namespace を選んでいるかを確認します。

```bash
oc get pod -n app-prod -l role=api
oc get pod -n app-prod -l role=frontend
oc get ns --show-labels
oc get events -n app-prod --sort-by=.lastTimestamp
```

## 運用メモ

- `podSelector: {}` は Namespace 内の全 Pod を対象にします。対象を絞る場合は明示的な label を使います。
- NetworkPolicy は許可リストとして扱います。特定宛先だけを拒否して残りを許可する用途は、標準の Kubernetes NetworkPolicy だけでは表現しにくいです。
- ingress と egress は別々に考えます。ingress を許可しても、送信元 Pod 側の egress deny によって通信できないことがあります。
- OpenShift Route 経由の外部アクセス、監視、ログ転送、イメージ pull、外部 Secret 取得など、アプリ以外の運用通信も棚卸しします。
- 変更時は `oc apply --server-side --dry-run=server -f <file>` で API 受理を確認してから適用します。
- 切り戻し用に、適用した YAML と削除コマンドを変更作業メモに残します。

## Sources

- Red Hat OpenShift Network policy: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/network_security/network-policy
- Kubernetes Network Policies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Kubernetes NetworkPolicy API: https://kubernetes.io/docs/reference/kubernetes-api/networking/network-policy-v1/

## Related

- [[20-architecture/networking|Networking]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]
