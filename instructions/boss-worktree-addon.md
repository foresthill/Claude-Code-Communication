# boss指示書 v3 - Git Worktree対応版（追加セクション）

## 🌳 Git Worktree管理（v3新機能）

### 概要
各workerが独立した環境で並行開発できるよう、Git Worktreeを管理します。

### 1. Worktree作成（新機能開始時）

PRESIDENTから新機能の指示を受けたら：

```bash
# プロジェクトルートに移動
cd [プロジェクトディレクトリ]

# 各workerに独立した作業環境を作成
git worktree add .worktrees/worker1-[機能名] -b worker1/[機能名]
git worktree add .worktrees/worker2-[機能名] -b worker2/[機能名]
git worktree add .worktrees/worker3-[機能名] -b worker3/[機能名]

# 各workerに通知
./agent-send.sh worker1 "【Worktree準備完了】
作業ディレクトリ: .worktrees/worker1-[機能名]
ブランチ: worker1/[機能名]
cd .worktrees/worker1-[機能名] で移動してください"

# worker2, worker3にも同様に通知
```

### 2. 進捗管理

```bash
# 各workerのブランチ状態を確認
git branch -a | grep worker
git log --oneline --graph --branches=worker* --max-count=20
```

### 3. マージ作業（全worker完了後）

全workerから【完了100%】報告を受けたら：

```bash
# 1. developブランチに移動
git checkout develop
git pull origin develop  # 最新を取得

# 2. 各workerのブランチをマージ
git merge --no-ff worker1/[機能名] -m "feat: worker1の[機能名]実装をマージ"
git merge --no-ff worker2/[機能名] -m "feat: worker2の[機能名]実装をマージ"
git merge --no-ff worker3/[機能名] -m "feat: worker3の[機能名]実装をマージ"

# 3. ビルド検証
npm install
npm run build
npm test

# 4. 成功したらプッシュ
git push origin develop
```

### 4. コンフリクト解決

```bash
# コンフリクトが発生した場合
git status  # 確認

# 該当workerに確認依頼
./agent-send.sh worker[番号] "【コンフリクト発生】
ファイル: [ファイル名]
該当箇所を確認して、解決方法を教えてください"

# 解決後
git add [ファイル名]
git commit -m "fix: [機能名]のコンフリクトを解決"
```

### 5. 完了後の片付け

```bash
# Worktreeを削除
git worktree remove .worktrees/worker1-[機能名]
git worktree remove .worktrees/worker2-[機能名]
git worktree remove .worktrees/worker3-[機能名]

# ブランチも削除（マージ済みの場合）
git branch -d worker1/[機能名]
git branch -d worker2/[機能名]
git branch -d worker3/[機能名]

# リモートブランチも削除
git push origin --delete worker1/[機能名]
git push origin --delete worker2/[機能名]
git push origin --delete worker3/[機能名]
```

### 6. PRESIDENTへの報告

```bash
./agent-send.sh president "【マージ完了報告】

機能: [機能名]

マージ状況:
- worker1/[機能名] ✅ マージ完了
- worker2/[機能名] ✅ マージ完了
- worker3/[機能名] ✅ マージ完了

ビルド結果:
- npm build: ✅ 成功
- npm test: ✅ 全テストパス

developブランチにプッシュ済みです。
次の指示をお待ちしています。"
```

## Worktreeのベストプラクティス

### DO ✅
- 各workerに独立した環境を提供
- こまめにブランチの状態を確認
- マージ前に必ずビルド検証
- 履歴を残すため--no-ffを使用
- 完了後は確実にクリーンアップ

### DON'T ❌
- 直接mainブランチにマージしない
- ビルドエラーを無視して進めない
- Worktreeを放置しない
- コンフリクトを適当に解決しない

## トラブルシューティング

### Worktreeが作成できない
```bash
# 既存のWorktreeを確認
git worktree list

# 強制的に削除が必要な場合
git worktree remove --force .worktrees/worker[番号]-[機能名]
```

### マージでコンフリクトが多発
- 各workerに事前に共通部分の調整を依頼
- 小さい単位でこまめにマージ
- developの最新を各workerに反映させる

### ビルドが失敗
```bash
# クリーンビルドを試す
rm -rf node_modules package-lock.json
npm install
npm run build
```

これらの機能により、真の並行開発が実現し、開発効率が大幅に向上します。
