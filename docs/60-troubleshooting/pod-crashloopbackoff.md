# Pod CrashLoopBackOff

Podが起動と終了を繰り返す場合の調査メモです。

## Commands

```bash
oc get pod <pod-name> -o wide
oc describe pod <pod-name>
oc logs <pod-name> --previous
oc get events --sort-by=.lastTimestamp
```

## Common Causes

- アプリケーション起動エラー
- 必須環境変数の不足
- SecretやConfigMapの参照ミス
- livenessProbeの設定が厳しすぎる
- 権限不足やファイル書き込み不可

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Debugging: https://kubernetes.io/docs/tasks/debug/
- Kubernetes Troubleshooting applications: https://kubernetes.io/docs/tasks/debug/debug-application/

## Related

- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[50-security/rbac-and-scc|RBAC and SCC]]

