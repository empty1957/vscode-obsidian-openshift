# ConfigMap and Secret

アプリケーション設定と機密情報の扱いを整理します。

## ConfigMap

- 非機密の設定値を保存します。
- 環境変数またはvolumeとしてPodへ渡します。
- 変更後にPod再起動が必要な構成か確認します。

## Secret

- パスワード、トークン、証明書などの機密情報を保存します。
- RBACで閲覧権限を制限します。
- Gitへ平文で保存しません。

## Related

- [[50-security/rbac-and-scc|RBAC and SCC]]

