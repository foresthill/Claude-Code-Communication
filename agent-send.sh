#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定ファイル
CONFIG_FILE="$SCRIPT_DIR/tmp/project_config.txt"

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "boss1") echo "multiagent:0.0" ;;
        "worker1") echo "multiagent:0.1" ;;
        "worker2") echo "multiagent:0.2" ;;
        "worker3") echo "multiagent:0.3" ;;
        *) echo "" ;;
    esac
}

# プロジェクトディレクトリ情報を取得
get_project_info() {
    if [[ -f "$CONFIG_FILE" ]]; then
        local project_dir=$(head -n 1 "$CONFIG_FILE" 2>/dev/null)
        if [[ -n "$project_dir" ]]; then
            echo "📁 プロジェクトディレクトリ: $project_dir"
        fi
    fi
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list
  $0 --status

利用可能エージェント:
  president - プロジェクト統括責任者
  boss1     - チームリーダー  
  worker1   - 実行担当者A
  worker2   - 実行担当者B
  worker3   - 実行担当者C

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "  president → president:0     (プロジェクト統括責任者)"
    echo "  boss1     → multiagent:0.0  (チームリーダー)"
    echo "  worker1   → multiagent:0.1  (実行担当者A)"
    echo "  worker2   → multiagent:0.2  (実行担当者B)" 
    echo "  worker3   → multiagent:0.3  (実行担当者C)"
    echo ""
    get_project_info
}

# ステータス表示
show_status() {
    echo "🔍 システムステータス:"
    echo "====================="
    
    # セッション確認
    echo "📺 Tmux Sessions:"
    if tmux has-session -t president 2>/dev/null; then
        echo "  ✅ president: 実行中"
    else
        echo "  ❌ president: 停止中"
    fi
    
    if tmux has-session -t multiagent 2>/dev/null; then
        echo "  ✅ multiagent: 実行中"
    else
        echo "  ❌ multiagent: 停止中"
    fi
    
    echo ""
    get_project_info
    
    # ログファイル確認
    if [[ -f "$SCRIPT_DIR/logs/send_log.txt" ]]; then
        local log_lines=$(wc -l < "$SCRIPT_DIR/logs/send_log.txt")
        echo "📝 送信ログ: $log_lines 件のメッセージ"
    else
        echo "📝 送信ログ: なし"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p "$SCRIPT_DIR/logs"
    echo "[$timestamp] $agent: SENT - \"$message\"" >> "$SCRIPT_DIR/logs/send_log.txt"
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        echo "💡 ヒント: ./setup.sh を実行してセッションを作成してください"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    # --statusオプション
    if [[ "$1" == "--status" ]]; then
        show_status
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 