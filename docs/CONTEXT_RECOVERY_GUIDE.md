# Claude Code Organization - コンテキスト喪失時の回復ガイド

## 🚨 「忘れてしまった」時の症状

### よくある症状
1. **セッション名エラー**
   ```
   Error: セッション 'multiagent' が見つかりません
   # 実際は 'project-multiagent' を使うべき
   ```

2. **役割の混乱**
   ```
   Claude: "私は何の役割でしたっけ？"
   ```

3. **プロジェクト情報の喪失**
   ```
   Claude: "どのディレクトリで作業していましたか？"
   ```

## 🔧 即座の回復方法

### ステップ1: プロジェクトコンテキストの再読み込み
```bash
# Claudeに以下を入力
@.claude/organization/PROJECT_CONTEXT.md
```

### ステップ2: 役割の再確認
```bash
# 各エージェントで実行
# PRESIDENTの場合
@.claude/organization/roles/president.md

# boss1の場合
@.claude/organization/roles/boss1.md

# workerの場合
@.claude/organization/roles/worker[番号].md
```

### ステップ3: セッション情報の確認
```bash
# 実際のセッション名を確認
tmux list-sessions

# プロジェクト設定を確認
cat .claude/organization/config.json
```

## 🎯 一般化されたワークフロー

### 1. プロジェクト初期化時の自動設定

```bash
#!/bin/bash
# init-project-sessions.sh

PROJECT_NAME=$(basename "$(pwd)")
PREFIX="${PROJECT_NAME%%-*}-"  # 最初の単語を使用

# 設定ファイルを自動生成
cat > .claude/organization/config.json << EOF
{
  "project_name": "$PROJECT_NAME",
  "session_prefix": "$PREFIX",
  "sessions": {
    "multiagent": "${PREFIX}multiagent",
    "president": "${PREFIX}president"
  }
}
EOF

echo "✅ プロジェクト '$PROJECT_NAME' の設定を作成しました"
echo "   セッション: ${PREFIX}multiagent, ${PREFIX}president"
```

### 2. セッション名の動的解決

```bash
# agent-send-universal.sh - どのプロジェクトでも動作

# 設定ファイルからセッション名を取得
get_session_name() {
    local role=$1
    local config_file=".claude/organization/config.json"
    
    if [[ -f "$config_file" ]]; then
        # 設定ファイルから読み取り
        jq -r ".sessions.$role // \"$role\"" "$config_file"
    else
        # デフォルト（プレフィックスなし）
        echo "$role"
    fi
}

MULTIAGENT_SESSION=$(get_session_name "multiagent")
PRESIDENT_SESSION=$(get_session_name "president")
```

### 3. 自動リカバリースクリプト

```bash
#!/bin/bash
# recover-context.sh - コンテキストを自動回復

echo "🔄 Claude Code Organization - コンテキスト回復"
echo "=============================================="

# 1. プロジェクト情報の収集
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_DIR")

# 2. 設定ファイルの確認
if [[ -f ".claude/organization/config.json" ]]; then
    echo "✅ 設定ファイル検出"
    SESSION_PREFIX=$(jq -r '.session_prefix' .claude/organization/config.json)
else
    echo "⚠️  設定ファイルなし - デフォルト使用"
    SESSION_PREFIX=""
fi

# 3. セッション状態の確認
echo ""
echo "📺 アクティブなセッション:"
tmux list-sessions | grep -E "(${SESSION_PREFIX}multiagent|${SESSION_PREFIX}president)" || echo "なし"

# 4. 回復コマンドの生成
echo ""
echo "🔧 回復手順:"
echo ""
echo "1. 各Claudeインスタンスで以下を実行:"
echo "   @.claude/organization/PROJECT_CONTEXT.md"
echo ""
echo "2. 役割に応じて:"
echo "   @.claude/organization/roles/[役割名].md"
echo ""
echo "3. 必要に応じてセッション再作成:"
echo "   ./.claude/organization/scripts/setup.sh $PROJECT_DIR"
```

## 📋 プロジェクトごとの設定例

### 例1: jinja-log-ai
```json
{
  "project_name": "jinja-log-ai",
  "session_prefix": "jinja-",
  "sessions": {
    "multiagent": "jinja-multiagent",
    "president": "jinja-president"
  }
}
```

### 例2: my-awesome-app
```json
{
  "project_name": "my-awesome-app",
  "session_prefix": "awesome-",
  "sessions": {
    "multiagent": "awesome-multiagent",
    "president": "awesome-president"
  }
}
```

### 例3: simple-project（プレフィックスなし）
```json
{
  "project_name": "simple-project",
  "session_prefix": "",
  "sessions": {
    "multiagent": "multiagent",
    "president": "president"
  }
}
```

## 🛡️ 予防策

### 1. スタートアップスクリプト
```bash
# .claude/organization/scripts/startup.sh
#!/bin/bash

echo "🚀 Claude Code Organization 起動"
echo "プロジェクト: $(basename $(pwd))"
echo ""
echo "重要情報:"
cat .claude/organization/PROJECT_CONTEXT.md | grep -A 3 "セッション名"
```

### 2. エラーメッセージの改善
```bash
# エラー時に正しい情報を表示
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ エラー: セッション '$SESSION_NAME' が見つかりません"
    echo ""
    echo "💡 ヒント:"
    echo "  1. 正しいセッション名を確認: cat .claude/organization/config.json"
    echo "  2. セッションを作成: ./.claude/organization/scripts/setup.sh"
    echo "  3. アクティブなセッション: tmux list-sessions"
fi
```

### 3. 定期的なリマインダー
```bash
# 10分ごとに重要情報を再表示
while true; do
    sleep 600
    echo "📌 リマインダー: セッション名は ${SESSION_PREFIX}multiagent です"
done &
```

## まとめ

コンテキスト喪失は避けられないが、適切な設計で迅速に回復可能：

1. **設定の外部化** - config.jsonで管理
2. **動的な解決** - プロジェクトに応じた自動調整
3. **明確な回復手順** - 標準化されたプロセス
4. **予防的措置** - エラーメッセージとドキュメント
