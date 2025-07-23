# Agent Communication System v2 - プロジェクトディレクトリ対応版

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー
- **worker1,2,3** (multiagent:0.1-3): 開発担当

## あなたの役割
- **PRESIDENT**: @.claude/organization/instructions/president.md
- **boss1**: @.claude/organization/instructions/boss.md
- **worker1,2,3**: @.claude/organization/instructions/worker.md

## プロジェクトディレクトリ設定
```bash
# 初期設定時に指定
./setup.sh [プロジェクトディレクトリ]
```

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## ステータス確認
```bash
# セッション状態とプロジェクト情報を表示
./agent-send.sh --status

# 利用可能なエージェント一覧
./agent-send.sh --list
```

## 基本フロー
```
PRESIDENT 
  ↓ (ビジョン)
boss1 
  ↓ (タスク分配)
workers (開発)
  ↓ (完了報告)
boss1 
  ↓ (統合報告)
PRESIDENT
```

## 🆕 v2新機能

### プロジェクトディレクトリ設定
- 各エージェントが指定されたディレクトリで作業
- 設定は`tmp/project_config.txt`に永続化
- 実際のプロジェクトファイルへのアクセス可能

### 拡張されたステータス監視
- セッション状態の可視化
- エラーハンドリングの改善
- 詳細なログ管理
