#!/bin/bash
# auto-detect-project.sh - プロジェクトを自動検出してセッション名を決定

# プロジェクト名からセッションプレフィックスを自動生成
get_session_prefix() {
    local project_dir="${1:-$(pwd)}"
    local project_name=$(basename "$project_dir")
    
    # プロジェクト名からプレフィックスを生成
    # 例: jinja-log-ai → jinja-
    #     my-awesome-app → awesome-
    #     simple-project → simple-
    
    # 方法1: 最初の単語を使用
    local prefix=$(echo "$project_name" | cut -d'-' -f1)
    
    # 方法2: 設定ファイルがあれば優先
    if [[ -f "$project_dir/.claude/organization/config.json" ]]; then
        local configured_prefix=$(jq -r '.session_prefix // empty' "$project_dir/.claude/organization/config.json" 2>/dev/null)
        if [[ -n "$configured_prefix" ]]; then
            prefix="$configured_prefix"
        fi
    fi
    
    # プレフィックスが空でなければハイフンを追加
    if [[ -n "$prefix" ]]; then
        echo "${prefix}-"
    else
        echo ""
    fi
}

# セッション名を生成
generate_session_names() {
    local project_dir="${1:-$(pwd)}"
    local prefix=$(get_session_prefix "$project_dir")
    
    echo "プロジェクト: $(basename "$project_dir")"
    echo "セッションプレフィックス: ${prefix:-なし}"
    echo ""
    echo "生成されるセッション名:"
    echo "  - ${prefix}multiagent"
    echo "  - ${prefix}president"
}

# メイン処理
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_session_names "$1"
fi
