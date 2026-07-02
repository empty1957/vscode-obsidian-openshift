# ADR 0001 Knowledge Base Structure

## Status

Accepted

## Context

OpenShiftの知識は、設計、運用、開発、セキュリティ、トラブルシュートなど複数の観点に分散します。Foamで扱いやすくするため、MarkdownファイルとWikiリンクを中心に整理します。

## Decision

番号付きフォルダで大分類を作り、各フォルダに`_index.md`を置く構成にします。入口はルートの[[README]]とし、各MOCから詳細ノートへリンクします。

## Consequences

- 初めて開いた人が全体像を追いやすくなります。
- ノート追加時の置き場所を判断しやすくなります。
- カテゴリをまたぐ話題はWikiリンクで関連付けます。

## Sources

- Red Hat OpenShift Documentation: https://docs.redhat.com/en/documentation/openshift_container_platform
- Kubernetes Documentation: https://kubernetes.io/docs/
- Markdown Guide: https://www.markdownguide.org/
