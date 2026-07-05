# ImagePullBackOff

Pod が `ImagePullBackOff` または `ErrImagePull` になる場合の調査メモです。Kubernetes はイメージ取得に失敗したコンテナをすぐには諦めず、再試行間隔を伸ばしながら pull を続けます。そのため、まずイベントに残っている失敗理由を確認してから、イメージ名、認証、権限、ネットワークの順に切り分けます。

## 最初に見る場所

```bash
oc get pod <pod-name> -n <namespace>
oc describe pod <pod-name> -n <namespace>
oc get events -n <namespace> --sort-by=.lastTimestamp
oc get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}{"\n"}'
oc get pod <pod-name> -n <namespace> -o jsonpath='{.spec.serviceAccountName}{"\n"}'
```

`oc describe pod` の `Events` に出る `Failed to pull image`、`unauthorized`、`not found`、`TLS handshake timeout` などの文言を起点にします。`ImagePullBackOff` という状態名だけでは原因を特定できません。

## よくある原因

| 観点 | 典型的な兆候 | 確認するもの |
| --- | --- | --- |
| イメージ参照 | `manifest unknown`、`not found` | レジストリ FQDN、リポジトリ名、タグ、digest |
| 認証 | `unauthorized`、`authentication required` | `imagePullSecrets` と ServiceAccount の紐付け |
| 権限 | OpenShift 内部レジストリの pull が失敗する | ImageStream の Namespace と `system:image-puller` 権限 |
| 疎通 | timeout、名前解決失敗、TLS エラー | Node からレジストリへの DNS、プロキシ、CA、ファイアウォール |
| pull 制限 | `toomanyrequests`、rate limit | 外部レジストリの制限、ミラー、認証済み pull |

## 認証情報を確認する

Pod が使う ServiceAccount に pull secret が付いているか確認します。Workload 側で `serviceAccountName` を明示している場合、`default` ServiceAccount ではなくその ServiceAccount を見ます。

```bash
oc get pod <pod-name> -n <namespace> -o jsonpath='{.spec.serviceAccountName}{"\n"}'
oc get serviceaccount <service-account> -n <namespace> -o yaml
oc get secret -n <namespace>
```

private registry 用の pull secret を ServiceAccount に紐付ける例です。

```bash
oc create secret docker-registry <pull-secret-name> \
  --docker-server=<registry-server> \
  --docker-username=<user-name> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n <namespace>

oc secrets link <service-account> <pull-secret-name> --for=pull -n <namespace>
oc get serviceaccount <service-account> -n <namespace> -o yaml
```

一時的に Pod spec の `imagePullSecrets` に直接書くこともできますが、同じ Namespace の複数 Workload で使うなら ServiceAccount に寄せると更新漏れを減らせます。

## 内部レジストリと ImageStream

OpenShift 内部レジストリや ImageStreamTag を使う場合は、イメージの所在 Namespace と実行 Namespace を分けて考えます。同一 Project 内では既定の権限で pull できる構成が多い一方、別 Project の ImageStream から pull する場合は、実行側 ServiceAccount に image pull 権限を付与する必要があります。

```bash
oc get imagestream -n <image-namespace>
oc get imagestreamtag <image-stream>:<tag> -n <image-namespace>
oc policy add-role-to-user system:image-puller \
  system:serviceaccount:<workload-namespace>:<service-account> \
  -n <image-namespace>
```

GitOps で管理している場合は、手動で付けた権限をその場限りにせず、RoleBinding や Kustomize overlay に反映します。

## 切り分けの順序

1. `oc describe pod` でイベントの失敗文言を読む。
2. Deployment、StatefulSet、Job など親リソースの `image` が期待するタグまたは digest か確認する。
3. Pod が使う ServiceAccount と `imagePullSecrets` を確認する。
4. Secret の Namespace が Pod と同じか確認する。Secret は別 Namespace から直接参照できません。
5. OpenShift 内部レジストリなら、ImageStream の Namespace と `system:image-puller` 権限を確認する。
6. timeout 系なら、レジストリ FQDN、企業プロキシ、信頼する CA、NetworkPolicy、egress firewall を確認する。
7. 修正後に Pod を再作成し、新しい Pod の Events で pull 成功を確認する。

```bash
oc rollout restart deploy/<deployment-name> -n <namespace>
oc get pod -n <namespace> -w
oc describe pod <new-pod-name> -n <namespace>
```

## 再発防止

- 本番 Workload は可変タグだけに依存せず、リリース手順でタグの存在を確認します。
- private registry の認証情報は有効期限と更新手順を運用メモに残します。
- Namespace ごとの標準 ServiceAccount、pull secret、外部レジストリ許可先をテンプレート化します。
- 障害時に `oc describe pod` の Events、対象イメージ、ServiceAccount、修正内容を記録します。

## Sources

- Red Hat OpenShift Container Platform 4.20 Images - Managing images: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/images/managing-images
- Red Hat OpenShift Container Platform 4.20 Authentication and authorization - Service accounts: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/authentication_and_authorization/using-service-accounts
- Kubernetes Images: https://kubernetes.io/docs/concepts/containers/images/
- Kubernetes Pull an Image from a Private Registry: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
- Kubernetes Debugging applications: https://kubernetes.io/docs/tasks/debug/debug-application/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/secrets-management|Secrets Management]]
