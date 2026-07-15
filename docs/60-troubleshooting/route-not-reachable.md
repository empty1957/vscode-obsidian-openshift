# Route Not Reachable

OpenShift の Route 経由でアプリケーションへ到達できない場合の切り分けメモです。Route は Service を外部公開する入口であり、実際の到達性は Route、Ingress Controller、Service、EndpointSlice、Pod、NetworkPolicy のどこで止まっているかを分けて確認します。

## 初動で確認すること

まず利用者から見えている症状を固定します。ブラウザ表示だけで判断せず、HTTP ステータス、名前解決、TLS エラー、発生時刻を残します。

```bash
ROUTE=<route-name>
NS=<namespace>

oc get route "$ROUTE" -n "$NS" -o wide
oc describe route "$ROUTE" -n "$NS"
oc get route "$ROUTE" -n "$NS" -o jsonpath='{.spec.host}{"\n"}'
curl -vk --connect-timeout 5 "https://$(oc get route "$ROUTE" -n "$NS" -o jsonpath='{.spec.host}')/"
```

`oc describe route` では、Route が参照する Service 名、`spec.port.targetPort`、TLS termination、`status.ingress` の admitted 状態を見ます。`status.ingress` が空、または admitted されていない場合は、Service より前に Ingress Controller 側の選択条件や host 重複を疑います。

## 切り分け順

| 観点 | 確認コマンド | 判断ポイント |
| --- | --- | --- |
| Route | `oc describe route <route> -n <ns>` | host、path、TLS termination、参照先 Service、targetPort が意図通りか |
| Service | `oc get svc <svc> -n <ns> -o yaml` | selector が Pod label と一致しているか、`port` と `targetPort` がアプリの待受ポートに合っているか |
| EndpointSlice | `oc get endpointslice -n <ns> -l kubernetes.io/service-name=<svc>` | Service selector に一致した Ready な Pod が endpoint として登録されているか |
| Pod | `oc get pod -n <ns> --show-labels` / `oc describe pod <pod> -n <ns>` | Ready になっているか、再起動や readinessProbe 失敗がないか |
| NetworkPolicy | `oc get networkpolicy -n <ns>` | Route から Service/Pod への通信、または Pod 側の依存先通信を遮断していないか |

EndpointSlice が `<none>` または空に見える場合、Route の問題ではなく Service selector、Pod label、readinessProbe、Pod の待受ポートを優先して確認します。Kubernetes では Service controller が selector に一致する Pod を EndpointSlice に反映します。

## Service と Pod の対応確認

Service が Pod を正しく選択しているかを、selector と label の両方から確認します。

```bash
SVC=<service-name>

oc get svc "$SVC" -n "$NS" -o jsonpath='{.spec.selector}{"\n"}'
oc get pod -n "$NS" --show-labels
oc describe svc "$SVC" -n "$NS"
oc get endpointslice -n "$NS" -l kubernetes.io/service-name="$SVC" -o wide
```

よくある不一致は、Deployment の template label を変えたが Service selector を更新していない、`app` と `app.kubernetes.io/name` を混在させている、Service の `targetPort` が Pod の containerPort 名と一致していない、readinessProbe が失敗して endpoint から外れている、というものです。

## 直接到達性の確認

Route の外側からだけでなく、クラスタ内から Service と Pod に直接アクセスして、どの層で止まるかを確認します。

```bash
oc run route-debug -n "$NS" --rm -i --tty --image=registry.access.redhat.com/ubi9/ubi-minimal -- /bin/bash

# debug Pod 内で実行
curl -vk "http://<service-name>.<namespace>.svc:<service-port>/"
curl -vk "http://<pod-ip>:<container-port>/"
```

Service には到達できるが Route だけ失敗する場合は、Route の host/path/TLS、Ingress Controller、DNS、外部ロードバランサを確認します。Pod IP には到達できるが Service に到達できない場合は、Service selector、port/targetPort、EndpointSlice、NetworkPolicy を確認します。

## 修正例

Service selector の不一致を直す場合は、先に現在値を保存してから変更します。

```bash
oc get svc "$SVC" -n "$NS" -o yaml > "backup-${SVC}-svc.yaml"
oc patch svc "$SVC" -n "$NS" --type merge -p '{"spec":{"selector":{"app":"<expected-label>"}}}'
oc get endpointslice -n "$NS" -l kubernetes.io/service-name="$SVC" -o wide
```

targetPort の不一致を直す場合は、Pod が実際に待ち受ける port 名または番号に合わせます。

```bash
oc get pod -n "$NS" -l app=<expected-label> -o jsonpath='{range .items[*].spec.containers[*].ports[*]}{.name}{" "}{.containerPort}{"\n"}{end}'
oc patch svc "$SVC" -n "$NS" --type merge -p '{"spec":{"ports":[{"name":"http","port":8080,"targetPort":"http"}]}}'
```

本番環境では selector や port の変更で即時に通信先が変わるため、変更前の YAML、変更理由、切り戻しコマンドを作業ログに残します。

## 検証

修正後は、Route の admitted 状態、EndpointSlice、クラスタ内疎通、外部疎通を順に確認します。

```bash
oc get route "$ROUTE" -n "$NS" -o yaml
oc get endpointslice -n "$NS" -l kubernetes.io/service-name="$SVC" -o wide
oc get events -n "$NS" --sort-by=.lastTimestamp | tail -20
curl -vk "https://$(oc get route "$ROUTE" -n "$NS" -o jsonpath='{.spec.host}')/"
```

復旧後も intermittent な失敗が残る場合は、Pod の再起動、readinessProbe の揺れ、Ingress Controller のログ、外部 DNS / ロードバランサのヘルスチェックを追加で確認します。

## Sources

- Red Hat OpenShift Container Platform 4.20 Routes: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/ingress_and_load_balancing/routes
- Kubernetes Service: https://kubernetes.io/docs/concepts/services-networking/service/
- Kubernetes Debug Services: https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/
- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform

## Related

- [[20-architecture/networking|Networking]]
- [[50-security/network-policy|Network Policy]]
