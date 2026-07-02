# Cluster Health Check

クラスタ状態を確認するための基本ランブックです。

## Preconditions

- `oc` CLIで対象クラスタへログイン済み
- 必要な閲覧権限があること

## Commands

```bash
oc whoami
oc get clusterversion
oc get nodes
oc get co
oc get pods -A | grep -v Running
oc get events -A --sort-by=.lastTimestamp
```

## Checkpoints

- ClusterOperatorにDegradedやProgressingが残っていないか
- NotReadyのNodeがないか
- CrashLoopBackOffやImagePullBackOffのPodがないか
- 直近イベントに繰り返し失敗がないか

## Related

- [[60-troubleshooting/pod-crashloopbackoff|Pod CrashLoopBackOff]]
- [[60-troubleshooting/imagepullbackoff|ImagePullBackOff]]

