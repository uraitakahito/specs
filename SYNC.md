# 本家追随 sync 手順 (uraitakahito/specs)

`webrecorder/specs` を追随しながら日本語訳するための、定期作業メモ。
本家が更新されたら毎回この手順を実行する。

## 原則

- `upstream → main → develop` の一方向のみ。
- `main` は本家ミラー。**翻訳を commit しない**。
- `develop → main` の逆流 (PR/merge) は**しない**。
- 翻訳は `develop`(既定ブランチ)に積む。
- `main` は**ローカル限定**。`origin`(fork)へ push しない — fork へ main を
  push すると継承 `publish.yml`(main トリガ)が英語を gh-pages に publish し、
  GitHub Pages の日本語版を上書きしてしまうため(本家の正典は upstream にある)。

## 手順

1. `main` を本家へ追随(無編集なので fast-forward。**push はしない**):

   ```sh
   git checkout main
   git fetch upstream
   git merge --ff-only upstream/main
   # 注意: git push origin main はしない (英語が Pages を上書きするのを防ぐ)
   ```

2. `develop` に取り込む:

   ```sh
   git checkout develop
   git merge main
   ```

3. conflict が出たら(= 訳した箇所が本家で変わった):
   - `wacz/1.1.1/index.md` の `<<<<<<<` / `=======` / `>>>>>>>` を開く。
   - `=======` 〜 `>>>>>>> main` 側が本家の新しい英語。
   - それを読んで日本語訳を更新し、マーカーを消す。
   - `git add wacz/1.1.1/index.md && git commit`

4. push:

   ```sh
   git push origin develop
   ```

## 便利

- 訳の全体(本家からの差分)を一望: `git diff main..develop -- wacz/1.1.1/index.md`
- 一発実行: `bash scripts/sync-upstream.sh`(conflict 時は停止して人手の翻訳を促す)

## clone 直後 (upstream remote が無いとき)

```sh
git remote add upstream https://github.com/webrecorder/specs.git
git fetch upstream
git remote set-head origin -a   # 既定ブランチ develop を反映
```
