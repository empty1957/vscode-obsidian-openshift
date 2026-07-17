# ConfigMap and Secret

OpenShift 上のアプリケーション設定を、機密ではない値と機密値に分けて管理するための基本ノートです。ConfigMap と Secret はどちらも Pod から参照できますが、更新の反映方法、監査対象、Git に置けるかどうかが異なります。

## 使い分け

| 用途 | 推奨リソース | 理由 |
| --- | --- | --- |
| ログレベル、機能フラグ、接続先 URL | ConfigMap | 機密ではない設定値としてレビューしやすい |
| パスワード、トークン、秘密鍵、証明書 | Secret | RBAC と Secret type によってアクセス範囲と用途を分けやすい |
| 環境ごとの差分を GitOps で管理する設定 | ConfigMap または暗号化済み Secret | 平文 Secret を Git に置かない |
| アプリが起動時だけ読む設定 | ConfigMap/Secret + rollout | env 参照は Pod 起動時に固定されるため |
| アプリがファイル変更を検知できる設定 | ConfigMap/Secret volume | volume 投影は最終的に更新される |

Secret は base64 で表現されますが、暗号化ではありません。値の秘匿は Kubernetes API への認可、etcd 暗号化、Git へ平文を置かない運用、外部シークレット管理との連携で担保します。

## 参照方法

### 環境変数として渡す

アプリが起動時に設定を読むだけなら、`envFrom` または `env.valueFrom` が単純です。ただし ConfigMap や Secret を更新しても、既存 Pod の環境変数は変わりません。Deployment ならロールアウトを明示します。

```bash
oc set env deployment/<deployment-name> --from=configmap/<configmap-name>
oc rollout restart deployment/<deployment-name>
oc rollout status deployment/<deployment-name>
```

### volume としてマウントする

アプリが設定ファイルや証明書ファイルを読む場合は volume にします。Kubernetes は ConfigMap/Secret の変更を kubelet 経由で volume に反映しますが、反映は即時ではなく最終的整合です。アプリ側がファイル変更を再読込できない場合は、結局 Pod の再起動が必要です。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
spec:
  template:
    spec:
      containers:
        - name: app
          image: quay.io/example/app:latest
          volumeMounts:
            - name: app-config
              mountPath: /etc/app
              readOnly: true
      volumes:
        - name: app-config
          configMap:
            name: app-config
```

`subPath` で 1 ファイルだけをマウントすると、ConfigMap/Secret の更新がコンテナ内のファイルへ反映されません。更新追従が必要な設定では、ディレクトリ単位でマウントするか、ロールアウトを前提にします。

## 作成と更新

```bash
oc create configmap app-config \
  --from-literal=LOG_LEVEL=info \
  --from-file=application.yaml=./application.yaml

oc create secret generic app-credentials \
  --from-literal=username=app \
  --from-literal=password='<password>'

oc get configmap app-config -o yaml
oc get secret app-credentials -o jsonpath='{.type}{"\n"}'
```

既存リソースを宣言的に更新する場合は、`--dry-run=client -o yaml | oc apply -f -` を使うと再実行しやすくなります。

```bash
oc create configmap app-config \
  --from-file=application.yaml=./application.yaml \
  --dry-run=client -o yaml | oc apply -f -
```

## 変更時の確認ポイント

- 参照先名が Deployment 側と一致しているか: `oc describe deployment/<name>`
- Pod が参照エラーで止まっていないか: `oc describe pod/<pod-name>`
- env 参照なら Pod 再作成後に値が変わったか: `oc exec <pod-name> -- printenv <KEY>`
- volume 参照ならコンテナ内のファイル内容が更新されたか: `oc exec <pod-name> -- cat /etc/app/application.yaml`
- アプリが再読込に対応していない場合、`oc rollout restart deployment/<name>` を実行したか
- Secret の参照権限を必要最小限の ServiceAccount に限定しているか

## 運用メモ

- Secret は Namespace 単位のリソースです。別 Namespace の Pod から直接参照できないため、必要な Namespace に配布する仕組みを決めます。
- 証明書やトークンをローテーションする場合は、Secret の内容更新だけで足りるか、Pod の再起動やアプリの reload API 呼び出しが必要かを事前に確認します。
- OpenShift の証明書運用では、Secret の内容更新が volume mount に伝播し、コンポーネント側がファイル変更を検知して hot reload する設計が使われる場合があります。自作アプリでも同じ前提を置けるかはアプリ実装次第です。
- `immutable: true` を付けた ConfigMap/Secret は誤更新を防げますが、変更時は新しい名前で作り直して参照先を切り替える運用になります。
- GitOps では ConfigMap は差分レビューし、Secret は Sealed Secrets、External Secrets Operator、SOPS などの暗号化・外部化方式を使います。

## トラブルシュート

```bash
oc get configmap,secret
oc describe pod <pod-name>
oc get events --sort-by=.lastTimestamp
oc rollout history deployment/<deployment-name>
oc rollout restart deployment/<deployment-name>
```

よくある原因は、キー名の typo、Secret type の不一致、ServiceAccount の権限不足、`subPath` 利用による更新未反映、アプリ側の再読込未対応です。`CreateContainerConfigError` や volume mount の Warning event が出ている場合は、まず Pod の `Events` と参照先リソース名を照合します。

## Sources

- Red Hat OpenShift Container Platform 4.20 release notes: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/release_notes/ocp-4-20-release-notes
- Red Hat OpenShift certificate configuration: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance/configuring-certificates
- Kubernetes ConfigMaps: https://kubernetes.io/docs/concepts/configuration/configmap/
- Kubernetes Secrets: https://kubernetes.io/docs/concepts/configuration/secret/

## Related

- [[50-security/rbac-and-scc|RBAC and SCC]]
