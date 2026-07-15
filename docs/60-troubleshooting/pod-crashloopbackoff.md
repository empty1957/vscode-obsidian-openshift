# Pod CrashLoopBackOff

Pod のコンテナが起動してすぐ終了し、再起動を繰り返すと `CrashLoopBackOff` と表示されます。これは原因名ではなく、Kubernetes が連続再起動を抑制するために再起動間隔を伸ばしている状態です。

## まず確認すること

```bash
oc get pod <pod-name> -o wide
oc describe pod <pod-name>
oc logs <pod-name> --previous
oc get events --sort-by=.lastTimestamp
```

- `oc get pod` で `RESTARTS` と `AGE` を見て、直近の変更後に再起動が増えたか確認します。
- `oc describe pod` で `State`、`Last State`、`Exit Code`、`Reason`、イベントを確認します。
- `oc logs --previous` で、直前に終了したコンテナのログを確認します。現在のコンテナがすぐ再起動する場合、通常の `oc logs` だけでは原因ログを取り逃がします。
- 複数コンテナ Pod では `-c <container-name>` を付けて対象コンテナを明示します。

## 原因別の切り分け

| 観点 | 確認すること | よくある対処 |
| --- | --- | --- |
| アプリケーション起動エラー | `--previous` ログ、終了コード、例外、設定読み込み失敗 | 起動引数、必須環境変数、依存サービス URL、マイグレーション状態を修正する |
| ConfigMap / Secret | `oc describe pod` の volume mount エラー、環境変数参照、キー名 | `[[40-development/configmap-and-secret|ConfigMap and Secret]]` のキー名、namespace、参照方法を確認する |
| livenessProbe | イベントの probe failed、アプリ起動時間、HTTP パス、ポート | 初期化に時間がかかる場合は `startupProbe` や `initialDelaySeconds` を検討する |
| 権限・SCC | Permission denied、書き込み不可、UID/GID、volume 権限 | 書き込み先を確認し、必要なら `[[50-security/rbac-and-scc|RBAC and SCC]]` と SCC 制約を確認する |
| リソース不足 | `OOMKilled`、メモリ上限、起動時の一時的な高負荷 | requests/limits、JVM やランタイムのメモリ設定、起動処理を見直す |
| イメージ・エントリポイント | command/args、実行ファイル、作業ディレクトリ | `oc get deploy <name> -o yaml` でマニフェストとイメージの期待値を照合する |

## 実務での調査順

1. 対象 Pod と owner を確認します。

    ```bash
    oc get pod <pod-name> -o jsonpath='{.metadata.ownerReferences[*].kind}{" "}{.metadata.ownerReferences[*].name}{"\n"}'
    oc get deploy,dc,statefulset,job,cronjob -o wide
    ```

2. 直前に終了したコンテナのログを保存します。

    ```bash
    oc logs <pod-name> -c <container-name> --previous > crashloop-previous.log
    ```

3. Pod の状態とイベントを保存します。

    ```bash
    oc describe pod <pod-name> > crashloop-describe.txt
    oc get pod <pod-name> -o yaml > crashloop-pod.yaml
    oc get events --sort-by=.lastTimestamp > crashloop-events.txt
    ```

4. 直近の rollout と差分を確認します。

    ```bash
    oc rollout history deploy/<deployment-name>
    oc rollout status deploy/<deployment-name>
    oc get deploy/<deployment-name> -o yaml
    ```

5. 影響範囲が広い場合は、復旧と原因調査を分けます。既知の正常 revision があるなら rollback を検討し、ログと YAML は先に保存します。

## 復旧判断のポイント

- `CrashLoopBackOff` は結果であり、修正対象はログ、イベント、マニフェスト、依存サービスのどれかにあります。
- livenessProbe が原因で再起動している場合、アプリ本体の異常なのか、probe 設計が厳しすぎるのかを分けて判断します。
- Secret や ConfigMap を修正しても、環境変数として読み込む設定は既存 Pod に自動反映されません。rollout restart や再デプロイが必要か確認します。
- OOMKilled の場合、単に limit を上げる前に、起動時だけ増えるメモリ、リーク、キャッシュ、JVM/Node.js/Go などランタイム設定を確認します。
- 本番では、調査コマンドの出力に Secret 値や個人情報が含まれないか確認してから共有します。

## 関連

- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[50-security/rbac-and-scc|RBAC and SCC]]
- [[60-troubleshooting/imagepullbackoff|ImagePullBackOff]]
- [[70-reference/oc-cheatsheet|oc Cheatsheet]]

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- OpenShift CLI documentation: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/cli_tools/openshift-cli-oc
- Kubernetes Pod lifecycle: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
- Kubernetes Debug Pods: https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
- Kubernetes Debug Running Pods: https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/
- Kubernetes Determine the Reason for Pod Failure: https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
