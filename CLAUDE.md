# Agent Communication System v3 - Git Worktree対応版

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー・PM
- **worker1,2,3** (multiagent:0.1-3): 並行開発担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## Git Worktree開発フロー

### 1. プロジェクト開始
```bash
# Worktree作成
./worktree-setup.sh . [機能名]
```

### 2. 並行開発
各workerが独立したWorktreeで開発：
- worker1: `.worktrees/worker1-[機能名]/`
- worker2: `.worktrees/worker2-[機能名]/`
- worker3: `.worktrees/worker3-[機能名]/`

### 3. 統合とマージ
```bash
# 全ブランチをマージ
./worktree-merge.sh [機能名]
```

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
```
PRESIDENT 
  ↓ (ビジョン)
boss1 
  ↓ (Worktree作成・タスク分配)
workers (並行開発)
  ↓ (完了報告)
boss1 (マージ・ビルド検証)
  ↓ (統合報告)
PRESIDENT
```

## 🆕 v3新機能

### Git Worktree統合
- 各workerが独立したブランチで開発
- 真の並行開発の実現
- コンフリクトの最小化

### 自動マージ機能
- PMによる統合作業の自動化
- コンフリクト解決支援
- マージ戦略の最適化

### ビルド検証
- 統合後の自動ビルド
- テスト実行
- デプロイ準備の確認

## 開発のベストプラクティス

### コミット規約
```
feat: 新機能
fix: バグ修正
docs: ドキュメント
style: スタイル変更
refactor: リファクタリング
test: テスト
chore: その他
```

### ブランチ戦略
- `main`: 本番環境
- `develop`: 開発統合
- `worker*/feature-*`: 各worker機能ブランチ

## トラブルシューティング

### Worktree関連
```bash
# Worktree一覧
git worktree list

# Worktree削除
git worktree remove .worktrees/worker1-[機能名]

# ブランチ確認
git branch -a
```

### マージコンフリクト
1. 該当workerに解決依頼
2. 手動解決
3. 再度マージ実行

## 設定ファイル
- `.claude/settings.json`: プロジェクト設定
- `.claude/settings.local.json`: ローカル設定（Git無視）
