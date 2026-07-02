# ImagePullBackOff

Pod が `ImagePullBackOff` になる場合は、コンテナランタイムが指定イメージを取得できず、kubelet が再試行間隔を伸ばしながら pull を続けている状態です。原因はイメージ名やタグの誤り、認証情報不足、ServiceAccount への pull secret 未設定、レジストリ到達性、OpenShift のプロジェクト間 ImageStream 権限に分けて確認します。

## First Checks

```bash
oc get pod <pod-name> -n <namespace>
oc describe pod <pod-name> -n <namespace>
oc get events -n <namespace> --sort-by=.lastTimestamp
oc get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}{"\n"}'
oc get pod <pod-name> -n <namespace> -o jsonpath='{.spec.serviceAccountName}{"\n"}'
```

`oc describe pod` の Events で `ErrImagePull`、`ImagePullBackOff`、`FailedToRetrieveImagePullSecret`、`unauthorized`、`manifest unknown`、`not found`、`i/o timeout` などの文言を確認し、最初の失敗理由を起点にします。BackOff の再試行ログだけを見ると、最初の認証エラーやタグ誤りを見落としやすくなります。

## Common Causes

- イメージ名、レジストリホスト、リポジトリパス、タグ、digest が誤っている。
- private registry 用の `imagePullSecrets` が Pod または ServiceAccount に設定されていない。
- Secret は存在するが、Pod と同じ namespace にない、名前が違う、認証情報が期限切れになっている。
- `imagePullPolicy: Always` または `:latest` により、ノードキャッシュではなく毎回 registry pull が必要になっている。
- レジストリの DNS、proxy、firewall、証明書、外向き通信制御でノードから到達できない。
- OpenShift internal registry / ImageStream を別 project から参照しているが、参照元 ServiceAccount に `system:image-puller` が付与されていない。

## Decision Flow

1. `oc describe pod` の Events で失敗理由を分類します。
2. `manifest unknown` や `not found` の場合は、ビルド済みイメージのタグまたは digest と Deployment の指定値を照合します。
3. `unauthorized` や `authentication required` の場合は、Pod の ServiceAccount と pull secret の紐付きを確認します。
4. `FailedToRetrieveImagePullSecret` の場合は、同じ namespace に Secret が存在するか、Pod/ServiceAccount 側の名前が一致しているか確認します。
5. `i/o timeout`、`connection refused`、TLS エラーの場合は、ノードから registry までの経路、proxy、証明書、クラスタの image registry 設定を確認します。
6. OpenShift の別 project にある ImageStream を参照している場合は、イメージを持つ project 側で `system:image-puller` 権限を付けます。

## Pull Secret Checks

```bash
oc get pod <pod-name> -n <namespace> -o yaml | sed -n '/imagePullSecrets:/,/containers:/p'
oc get sa <service-account> -n <namespace> -o yaml
oc get secret <pull-secret-name> -n <namespace> -o jsonpath='{.type}{"\n"}'
```

Kubernetes では、Pod が private registry から pull するには、対象 Pod と同じ namespace にある Secret を `imagePullSecrets` として参照する必要があります。OpenShift では ServiceAccount に pull secret を紐付けておくと、その ServiceAccount を使う Pod へ適用できます。

```bash
oc create secret docker-registry <pull-secret-name> \
  --docker-server=<registry-server> \
  --docker-username=<user-name> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n <namespace>

oc secrets link <service-account> <pull-secret-name> --for=pull -n <namespace>
```

Secret を作成・更新した後は、既存 Pod が自動的に復旧しない場合があります。Deployment / DeploymentConfig / Job などの管理元を確認し、必要に応じて rollout restart や Pod 再作成で新しい Pod spec を使わせます。

## Cross-project OpenShift Images

OpenShift の internal registry や ImageStream を project 間で参照する場合、参照元 project の ServiceAccount に、イメージを持つ project 側で `system:image-puller` を付与します。

```bash
oc policy add-role-to-user \
  system:image-puller system:serviceaccount:<consumer-project>:<service-account> \
  --namespace=<image-owner-project>
```

namespace または ServiceAccount を作った直後は、OpenShift が ServiceAccount 用 pull secret を払い出す前に Pod が作られることがあります。その場合は ServiceAccount の secret 反映を待ってから Pod を再作成します。

## Recovery Notes

- タグの再利用を前提にしない本番 workload では、可能なら digest 指定でリリース対象を固定します。
- `:latest` やタグ省略は `imagePullPolicy: Always` になりやすいため、registry 障害や認証期限切れの影響を受けやすくなります。
- Secret の中身をログやチケットに貼らないでください。確認時は Secret 名、namespace、type、更新時刻、紐付き先だけを共有します。
- CI/CD では、イメージ push 完了前に Deployment を更新していないか、タグ生成と rollout の順序を確認します。

## Sources

- Red Hat OpenShift Documentation: Managing images: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/images/managing-images
- Kubernetes Documentation: Images: https://kubernetes.io/docs/concepts/containers/images/
- Kubernetes Documentation: Pull an Image from a Private Registry: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/secrets-management|Secrets Management]]
- [[60-troubleshooting/pod-crashloopbackoff|Pod CrashLoopBackOff]]
