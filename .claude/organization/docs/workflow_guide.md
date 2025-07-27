# 📚 物語執筆AIチーム ワークフローガイド

## 🎯 現在のプロジェクト: 「最後の旋盤」

### プロジェクト状況
- **テーマ**: 町工場の職人魂と技術継承
- **進捗**: 初稿完成（執筆フェーズ100%）
- **次のステップ**: 編集フェーズ

## 👥 チーム構成とコマンド

### エージェント一覧
| 役割 | エージェント名 | tmuxセッション | 責任範囲 |
|------|---------------|---------------|----------|
| 編集長 | editor-in-chief | president | 企画・最終承認 |
| 編集者 | editor | boss1 (multiagent:0.0) | プロット・進行管理 |
| ライター | writer | worker1 (multiagent:0.1) | 初稿執筆 |
| 敏腕編集者 | copy-editor | worker2 (multiagent:0.2) | 文章編集・推敲 |
| 校正者 | proofreader | worker3 (multiagent:0.3) | 最終校正 |

## 📮 メッセージ送信方法

### 基本的な送信
```bash
# 物語チーム専用スクリプトを使用
./agent-send-story.sh [エージェント名] "[メッセージ]"

# 例：編集者に送信
./agent-send-story.sh editor "プロットを確認してください"

# 例：敏腕編集者に初稿を送信
./agent-send-story.sh copy-editor "初稿が完成しました" --attach .claude/organization/stories/drafts/saigo_no_senban_v1_initial.md
```

### 注意事項
- ❌ `./agent-send.sh editor` は動作しません（editorマッピングなし）
- ✅ `./agent-send-story.sh editor` を使用してください

## 🔄 正しいワークフロー

### 1. 企画段階（完了）
```
editor-in-chief「町工場の物語を企画」
    ↓
editor「プロット作成」
```

### 2. 執筆段階（完了）
```
editor → writer「プロットに基づいて執筆を」
    ↓
writer「初稿完成」→ stories/drafts/saigo_no_senban_v1_initial.md
```

### 3. 編集段階（現在）← 今ここ
```bash
# 敏腕編集者に初稿を送る
./agent-send-story.sh copy-editor "初稿『最後の旋盤』が完成しました。編集をお願いします。" --attach .claude/organization/stories/drafts/saigo_no_senban_v1_initial.md

# 進捗を更新
./story-status.sh --update editing 10
```

### 4. 校正段階（次の段階）
```bash
# 編集完了後、校正者に送る
./agent-send-story.sh proofreader "編集稿が完成しました。最終校正をお願いします。" --attach .claude/organization/stories/revisions/[編集稿ファイル名]
```

### 5. 最終承認
```bash
# 編集長に最終稿を報告
./agent-send-story.sh editor-in-chief "『最後の旋盤』が完成しました。最終承認をお願いします。" --attach .claude/organization/stories/final/[最終稿ファイル名]
```

## 🛠️ 便利なコマンド

### 進捗確認
```bash
# 現在の進捗状況
./story-status.sh --current

# 進捗を更新（例：編集50%）
./story-status.sh --update editing 50
```

### バージョン管理
```bash
# 編集版を保存
./story-version.sh save edited_story.md "第1次編集完了"

# バージョン一覧
./story-version.sh list
```

### ログ確認
```bash
# 通信ログを確認
tail -20 .claude/organization/logs/communication_log.txt

# 進捗ログを確認
cat .claude/organization/logs/progress.log
```

## ⚠️ トラブルシューティング

### 「不明なエージェント」エラーが出る場合
1. 物語チーム用スクリプトを使用しているか確認
   - ❌ `./agent-send.sh`
   - ✅ `./agent-send-story.sh`

2. エージェント名が正しいか確認
   - ❌ `boss1`, `worker1`（開発チーム用）
   - ✅ `editor`, `writer`（物語チーム用）

### メッセージが届かない場合
```bash
# tmuxセッションを確認
tmux ls

# エージェントが起動しているか確認
tmux attach-session -t multiagent
```

## 📝 現在の優先タスク

1. **初稿の編集を開始**
   - 敏腕編集者に初稿を送信
   - 文章の流れ、構成、表現を改善

2. **進捗管理の更新**
   - 編集フェーズの進捗を追跡
   - 各エージェントの作業状況を確認

3. **品質向上**
   - 「最後の旋盤」を洗練された作品に
   - 読者に感動を与える物語に仕上げる