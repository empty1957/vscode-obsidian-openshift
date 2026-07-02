# App Deployment Flow

アプリケーションをOpenShiftへデプロイする基本の流れです。

## Flow

1. Projectを選択または作成します。
2. イメージ、BuildConfig、またはGitOps経由でDeploymentを作成します。
3. Serviceを作成し、Podへ安定した入口を作ります。
4. 必要に応じてRouteを作成します。
5. ConfigMap、Secret、PVCを紐づけます。
6. ログ、イベント、Ready状態を確認します。

## Verification

```bash
oc get deploy,pod,svc,route
oc logs deploy/<deployment-name>
oc describe pod <pod-name>
```

## Related

- [[40-development/configmap-and-secret|ConfigMap and Secret]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]

