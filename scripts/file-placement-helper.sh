#!/bin/bash
# ファイル配置ヘルパースクリプト
# エージェントが適切な場所にファイルを配置するためのヘルパー関数

# プロジェクトルートを自動検出
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# ディレクトリ作成
ensure_directories() {
    mkdir -p "$PROJECT_ROOT/.claude/organization/reports"
    mkdir -p "$PROJECT_ROOT/.claude/organization/logs"
    mkdir -p "$PROJECT_ROOT/.claude/organization/tmp"
}

# ファイル配置関数
place_file() {
    local file_type=$1
    local file_name=$2
    local content=$3
    
    ensure_directories
    
    case $file_type in
        "report")
            local file_path="$PROJECT_ROOT/.claude/organization/reports/$file_name"
            echo "$content" > "$file_path"
            echo "Report saved to: $file_path"
            ;;
        "log")
            local file_path="$PROJECT_ROOT/.claude/organization/logs/$file_name"
            echo "$content" > "$file_path"
            echo "Log saved to: $file_path"
            ;;
        "tmp")
            local file_path="$PROJECT_ROOT/.claude/organization/tmp/$file_name"
            echo "$content" > "$file_path"
            echo "Temporary file saved to: $file_path"
            ;;
        *)
            echo "Error: Unknown file type '$file_type'"
            echo "Valid types: report, log, tmp"
            return 1
            ;;
    esac
}

# 使用例を表示
show_usage() {
    cat << EOF
ファイル配置ヘルパーの使用方法:

1. このスクリプトをソース:
   source ./scripts/file-placement-helper.sh

2. ファイルを配置:
   place_file "report" "analysis_2025-07-12.md" "レポート内容"
   place_file "log" "boss1_to_worker1.md" "ログ内容"
   place_file "tmp" "draft_plan.md" "一時ファイル内容"

3. ファイル命名規則:
   - レポート: [目的]_[日付].md
   - ログ: [送信者]_to_[受信者]_[日付].md
   - 一時ファイル: tmp_[内容]_[タイムスタンプ].md
EOF
}

# コマンドとして実行された場合
if [[ $# -eq 0 ]]; then
    show_usage
elif [[ $# -eq 3 ]]; then
    place_file "$1" "$2" "$3"
else
    echo "Error: Invalid number of arguments"
    show_usage
    exit 1
fi
