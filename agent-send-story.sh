#!/bin/bash

# 📮 物語執筆チーム用メッセージ送信スクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 既存のagent-send.shを使用
AGENT_SEND="./agent-send.sh"

# エージェントマッピング（物語執筆用）
# 連想配列の代わりに関数で実装
get_story_agent_target() {
    case "$1" in
        "editor-in-chief") echo "president" ;;
        "editor") echo "boss1" ;;
        "writer") echo "worker1" ;;
        "copy-editor") echo "worker2" ;;
        "proofreader") echo "worker3" ;;
        *) echo "" ;;
    esac
}

# 使用方法を表示
show_usage() {
    cat << EOF
📮 物語執筆チーム用メッセージ送信

使用方法:
  $0 <エージェント> "<メッセージ>" [--attach <ファイル>]
  $0 --list

エージェント:
  editor-in-chief - 編集長（企画・最終承認）
  editor         - 編集者（プロット・進行管理）
  writer         - 天才ライター（初稿執筆）
  copy-editor    - 敏腕編集者（文章編集）
  proofreader    - 校正者（最終校正）

オプション:
  --attach <file> - 原稿ファイルを添付

例:
  $0 editor "新しい短編の企画です。テーマは「再生」でお願いします。"
  $0 writer "プロットができました。執筆をお願いします。" --attach plots/plot_outline.md
  $0 --list
EOF
}

# エージェント一覧表示
show_agents() {
    echo -e "${BLUE}📚 物語執筆チーム${NC}"
    echo "=========================="
    echo -e "  ${YELLOW}editor-in-chief${NC} → 編集長（企画・最終承認）"
    echo -e "  ${YELLOW}editor${NC}          → 編集者（プロット・進行管理）"
    echo -e "  ${YELLOW}writer${NC}          → 天才ライター（初稿執筆）"
    echo -e "  ${YELLOW}copy-editor${NC}     → 敏腕編集者（文章編集）"
    echo -e "  ${YELLOW}proofreader${NC}     → 校正者（最終校正）"
}

# ファイル内容を含むメッセージを生成
create_message_with_attachment() {
    local message="$1"
    local file="$2"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}エラー: ファイル '$file' が見つかりません${NC}" >&2
        exit 1
    fi
    
    # ファイル情報を追加
    local filename=$(basename "$file")
    local filesize=$(wc -c < "$file")
    local wordcount=$(wc -m < "$file")
    
    cat << EOF
$message

【添付ファイル】
ファイル名: $filename
文字数: $wordcount 文字
サイズ: $filesize バイト

--- ファイル内容 ここから ---
$(cat "$file")
--- ファイル内容 ここまで ---
EOF
}

# 役割確認メッセージを追加
add_role_message() {
    local agent="$1"
    local message="$2"
    
    case "$agent" in
        "editor-in-chief")
            echo "あなたはeditor-in-chief（編集長）です。"
            ;;
        "editor")
            echo "あなたはeditor（編集者）です。"
            ;;
        "writer")
            echo "あなたはwriter（天才ライター）です。"
            ;;
        "copy-editor")
            echo "あなたはcopy-editor（敏腕編集者）です。"
            ;;
        "proofreader")
            echo "あなたはproofreader（校正者）です。"
            ;;
    esac
    
    echo ""
    echo "$message"
}

# 通信ログを記録
log_communication() {
    local from="${STORY_USER:-user}"
    local to="$1"
    local message="$2"
    local logfile=".claude/organization/logs/communication_log.txt"
    
    mkdir -p "$(dirname "$logfile")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $from → $to: $message" >> "$logfile"
}

# メイン処理
main() {
    # ヘルプオプション
    if [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    # リストオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    # 引数チェック
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local story_agent="$1"
    local message="$2"
    local attach_file=""
    
    # オプション解析
    shift 2
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --attach)
                attach_file="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}エラー: 不明なオプション '$1'${NC}"
                exit 1
                ;;
        esac
    done
    
    # エージェント名の変換
    local real_agent=$(get_story_agent_target "$story_agent")
    if [[ -z "$real_agent" ]]; then
        echo -e "${RED}エラー: 不明なエージェント '$story_agent'${NC}"
        echo "利用可能なエージェント: editor-in-chief editor writer copy-editor proofreader"
        exit 1
    fi
    
    # メッセージの準備
    local full_message=$(add_role_message "$story_agent" "$message")
    
    # ファイル添付がある場合
    if [[ -n "$attach_file" ]]; then
        full_message=$(create_message_with_attachment "$full_message" "$attach_file")
    fi
    
    # 通信ログを記録
    log_communication "$story_agent" "$message"
    
    # 実際の送信
    echo -e "${BLUE}📤 送信中: $story_agent${NC}"
    "$AGENT_SEND" "$real_agent" "$full_message"
    
    # 進捗ログ更新のヒント
    case "$story_agent" in
        "editor")
            if [[ "$message" == *"プロット"* ]]; then
                echo -e "${YELLOW}💡 ヒント: プロット作成が始まったら以下で進捗を更新できます:${NC}"
                echo "   ./story-status.sh --update plotting 10"
            fi
            ;;
        "writer")
            if [[ "$message" == *"執筆"* ]]; then
                echo -e "${YELLOW}💡 ヒント: 執筆が始まったら以下で進捗を更新できます:${NC}"
                echo "   ./story-status.sh --update writing 10"
            fi
            ;;
        "copy-editor")
            if [[ "$message" == *"編集"* ]]; then
                echo -e "${YELLOW}💡 ヒント: 編集が始まったら以下で進捗を更新できます:${NC}"
                echo "   ./story-status.sh --update editing 10"
            fi
            ;;
        "proofreader")
            if [[ "$message" == *"校正"* ]]; then
                echo -e "${YELLOW}💡 ヒント: 校正が始まったら以下で進捗を更新できます:${NC}"
                echo "   ./story-status.sh --update proofing 10"
            fi
            ;;
    esac
}

# スクリプト実行
main "$@"