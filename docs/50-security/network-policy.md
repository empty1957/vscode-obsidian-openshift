# Network Policy

Namespace内外のPod通信を制御するための設計メモです。

## Basic Policy

- デフォルト拒否にするか検討します。
- アプリケーションに必要なingress/egressだけ許可します。
- DNS、監視、ログ転送など基盤通信を忘れないようにします。

## Checkpoints

- label selectorが意図したPodを選んでいるか
- Namespace selectorが広すぎないか
- egress制御で外部APIやDNSを遮断していないか

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Security: https://kubernetes.io/docs/concepts/security/
- OpenShift Security and compliance: https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/security_and_compliance

## Related

- [[20-architecture/networking|Networking]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]

