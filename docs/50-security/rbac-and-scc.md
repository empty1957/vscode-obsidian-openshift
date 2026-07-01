# RBAC and SCC

OpenShiftでの操作権限とPod実行制約の整理です。

## RBAC

- User、Group、ServiceAccountにRoleまたはClusterRoleを割り当てます。
- 最小権限を基本にします。
- Namespace単位の権限とクラスタ全体の権限を分けて考えます。

## SCC

- Podがどの権限で実行できるかを制御します。
- privileged、hostPath、runAsUser、SELinuxなどに影響します。
- 安易に強いSCCを付与しないようにします。

## Useful Commands

```bash
oc auth can-i <verb> <resource> -n <namespace>
oc adm policy who-can <verb> <resource> -n <namespace>
```

## Related

- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[50-security/secrets-management|Secrets Management]]

