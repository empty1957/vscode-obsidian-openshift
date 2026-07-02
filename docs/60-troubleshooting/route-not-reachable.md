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

## Related

- [[20-architecture/networking|Networking]]
- [[50-security/network-policy|Network Policy]]

