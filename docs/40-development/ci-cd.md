# CI/CD

OpenShift の CI/CD は、ビルド、検査、承認、デプロイ、切り戻しをどの責務に分けるかを先に決めると整理しやすいです。単一のツール名から始めるのではなく、成果物と権限境界を明確にしてから OpenShift Pipelines、外部 CI、GitOps を組み合わせます。

## 代表的な構成

| 構成 | 向いている使いどころ | 注意点 |
| --- | --- | --- |
| OpenShift Pipelines | クラスタ内で Tekton ベースの Pipeline / Task / PipelineRun としてビルドから検査まで管理したい場合 | Pipeline 用 ServiceAccount、Task の権限、ワークスペース、Secret の扱いを明示する |
| BuildConfig | OpenShift の既存 BuildConfig、S2I、Dockerfile ビルドを継続利用する場合 | 新規設計では Pipelines や GitOps との責務分担を確認する |
| GitHub Actions などの外部 CI | リポジトリ側でテスト、静的解析、イメージ作成、署名、PR チェックを寄せたい場合 | クラスタ資格情報を長期 Secret として置く場合は漏えい時の影響範囲を最小化する |
| OpenShift GitOps | Argo CD ベースで Kubernetes マニフェストの desired state を継続的に反映したい場合 | CI から直接 `oc apply` する範囲と、GitOps が同期する範囲を重ねない |

## 推奨する責務分担

CI は「変更を検査して、再現可能な成果物を作る」責務に寄せます。

- unit test、lint、SAST、container scan を実行する
- image digest を固定して成果物を識別できるようにする
- SBOM、署名、スキャン結果など、後から監査できる証跡を保存する
- 環境別 manifest の変更は PR として残す

CD は「承認済みの desired state をクラスタへ反映する」責務に寄せます。

- staging と production の差分を Git 上で確認できるようにする
- 手動承認が必要な環境は GitHub Environments、Argo CD AppProject、OpenShift RBAC などで境界を作る
- 反映後は rollout、Pod Ready、Route、ログ、イベントを確認する
- 切り戻しは直前の image digest または manifest commit に戻す手順として残す

## 外部 CI から OpenShift を操作する場合

外部 CI から `oc` を使う場合は、便利さと資格情報リスクを分けて判断します。長期 token や kubeconfig を CI Secret に置く構成は単純ですが、漏えい時にクラスタ操作権限が残ります。GitHub Actions では OIDC によりクラウド側の短期 credential を取得できるため、利用できる環境では長期 Secret を減らす設計を優先します。

最小権限の確認例:

```bash
oc create serviceaccount deployer -n <namespace>
oc adm policy add-role-to-user edit -z deployer -n <namespace>
oc auth can-i patch deployment/<deployment-name> --as=system:serviceaccount:<namespace>:deployer -n <namespace>
```

本番環境では `edit` を広く付与する前に、必要な API 操作だけで足りるか確認します。CI が実行するコマンドを先に列挙し、`oc auth can-i` で実権限を確認してから token を払い出します。

## GitOps と直接 apply を混在させるときの判断

GitOps 管理対象の Deployment、Service、Route、ConfigMap を CI から直接 `oc apply` すると、Argo CD の同期と CI の変更が競合します。混在を避けられない場合は、次のどちらかに寄せます。

- CI は image build と manifest 更新 PR までを担当し、クラスタ反映は GitOps に任せる
- CI が直接 deploy する namespace と、GitOps が管理する namespace / resource を明確に分ける

運用上は、production ほど GitOps に寄せると監査しやすくなります。緊急修正で手動 `oc patch` を行った場合も、後で Git 側へ同じ変更を戻して drift を解消します。

## PipelineRun の確認例

```bash
oc get pipelinerun -n <namespace>
oc describe pipelinerun <pipeline-run-name> -n <namespace>
oc logs -l tekton.dev/pipelineRun=<pipeline-run-name> -n <namespace> --all-containers
```

失敗時は、TaskRun の失敗 step、参照した Secret、Workspace の PVC、image pull、権限不足を順に見ます。アプリの rollout 失敗と Pipeline 自体の失敗を混同しないように、`PipelineRun` / `TaskRun` / `Deployment` / `Pod` のどの層で止まったかを分けます。

## デプロイ後の確認

```bash
oc rollout status deploy/<deployment-name> -n <namespace>
oc get deploy,pod,svc,route -n <namespace>
oc describe deploy/<deployment-name> -n <namespace>
oc logs deploy/<deployment-name> -n <namespace> --tail=100
```

切り戻し前には、現在の image、直近の ReplicaSet、イベント、変更 commit を保存します。`oc rollout undo` は緊急復旧には便利ですが、GitOps 管理下では Git の desired state も戻さないと再同期で元に戻る可能性があります。

## 設計時のチェックリスト

- build と deploy を同じ権限で実行していないか
- production 反映に人の承認または明確な promotion commit があるか
- image tag だけでなく digest または commit SHA で追跡できるか
- Secret、kubeconfig、registry credential の保管場所とローテーション手順が決まっているか
- 失敗時に Pipeline、GitOps、Deployment のどこを見ればよいか runbook 化されているか
- 手動変更後に Git 側へ戻す drift 解消手順があるか

## Sources

- Red Hat OpenShift Pipelines 4.20: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/pipelines/index
- Red Hat OpenShift BuildConfig build strategies 4.20: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/builds_using_buildconfig/build-strategies
- Red Hat OpenShift GitOps 4.20: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/gitops/index
- GitHub Actions OpenID Connect: https://docs.github.com/en/actions/concepts/security/openid-connect
- GitHub Actions secrets: https://docs.github.com/actions/security-guides/using-secrets-in-github-actions
- Kubernetes rollout undo: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/kubectl_rollout_undo/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/_index|Security]]
