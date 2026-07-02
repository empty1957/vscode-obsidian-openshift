# Secrets Management

OpenShiftでの機密情報管理に関するノートです。

## Principles

- SecretをGitに平文で保存しません。
- 閲覧できる人とServiceAccountを最小限にします。
- ローテーション手順を明文化します。
- 外部Secret管理基盤の利用を検討します。

## Questions

- Secretの所有者は誰か
- 更新時にPod再起動が必要か
- 失効、漏えい、ローテーション時の連絡経路はあるか

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Security: https://kubernetes.io/docs/concepts/security/
- OpenShift Security and compliance: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance

## Related

- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[50-security/rbac-and-scc|RBAC and SCC]]

