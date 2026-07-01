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

## Related

- [[20-architecture/networking|Networking]]
- [[60-troubleshooting/route-not-reachable|Route Not Reachable]]

