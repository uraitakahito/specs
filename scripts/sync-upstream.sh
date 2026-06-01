#!/usr/bin/env bash
#
# 本家 (webrecorder/specs) を追随する定期 sync。詳細は ../SYNC.md。
#
#   upstream → main (ミラー) → develop (翻訳)
#
# main を本家へ ff し、develop に merge する。conflict が出たら止まるので、
# その場合は衝突箇所を訳し直して `git add` → `git commit` → `git push` する。
set -euo pipefail

# upstream remote が無ければ案内して終了
if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "upstream remote がありません。先に:" >&2
  echo "  git remote add upstream https://github.com/webrecorder/specs.git" >&2
  exit 1
fi

git fetch upstream

# main を本家ミラーに (無編集なので ff のはず)
git checkout main
git merge --ff-only upstream/main
git push origin main

# develop に取り込む
git checkout develop
if git merge --no-edit main; then
  git push origin develop
  echo "sync 完了: develop を本家に追随しました"
else
  echo "conflict: 衝突箇所を訳し直して 'git add' → 'git commit' → 'git push origin develop' してください" >&2
  exit 1
fi
