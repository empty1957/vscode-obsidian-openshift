# Route Not Reachable

Route経由でアプリケーションへ到達できない場合の調査メモです。

## Commands

```bash
oc get route
oc describe route <route-name>
oc get svc <service-name> -o yaml
oc get endpoints <service-name>
oc get pod -l <label-selector>
```

## Checkpoints

- Routeのhostが正しいか
- Service selectorがPod labelと一致しているか
- Service portとtargetPortが正しいか
- PodがReadyになっているか
- NetworkPolicyで通信が遮断されていないか

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Kubernetes Debugging: https://kubernetes.io/docs/tasks/debug/
- Kubernetes Troubleshooting applications: https://kubernetes.io/docs/tasks/debug/debug-application/

## Related

- [[20-architecture/networking|Networking]]
- [[50-security/network-policy|Network Policy]]

