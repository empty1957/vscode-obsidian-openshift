# ImagePullBackOff

コンテナイメージを取得できない場合の調査メモです。

## Commands

```bash
oc describe pod <pod-name>
oc get secret -n <namespace>
oc get events --sort-by=.lastTimestamp
```

## Common Causes

- イメージ名またはタグが誤っている
- レジストリ認証情報が不足している
- ImagePullSecretがServiceAccountに紐づいていない
- レジストリへのネットワーク疎通がない

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Debugging: https://kubernetes.io/docs/tasks/debug/
- Kubernetes Troubleshooting applications: https://kubernetes.io/docs/tasks/debug/debug-application/

## Related

- [[40-development/app-deployment-flow|App Deployment Flow]]
- [[50-security/secrets-management|Secrets Management]]

