#!/bin/bash

# 📊 物語執筆進捗管理スクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ベースディレクトリ
BASE_DIR=".claude/organization"

# 使用方法を表示
show_usage() {
    cat << EOF
📊 物語執筆進捗管理ツール

使用方法:
  $0 --current              - 現在の進捗状況を表示
  $0 --timeline             - タイムライン表示
  $0 --update <phase> <%>   - 進捗を更新
  $0 --report               - 詳細レポート生成

フェーズ:
  planning   - 企画段階
  plotting   - プロット作成
  writing    - 執筆
  editing    - 編集
  proofing   - 校正

例:
  $0 --current
  $0 --update writing 60
  $0 --report > progress_report.md
EOF
}

# 現在の進捗を取得
get_current_progress() {
    local progress_file="$BASE_DIR/tmp/progress.json"
    
    # 進捗ファイルが存在しない場合は初期化
    if [[ ! -f "$progress_file" ]]; then
        cat > "$progress_file" << EOF
{
  "planning": 0,
  "plotting": 0,
  "writing": 0,
  "editing": 0,
  "proofing": 0,
  "current_phase": "planning",
  "started": "$(date +%Y-%m-%d)",
  "updated": "$(date +%Y-%m-%d\ %H:%M:%S)"
}
EOF
    fi
    
    cat "$progress_file"
}

# 進捗バーを表示
show_progress_bar() {
    local percent=$1
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" "$percent"
}

# 現在の状況を表示
show_current_status() {
    echo -e "${PURPLE}📊 物語執筆進捗状況${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 進捗データを読み込む
    local progress_json=$(get_current_progress)
    
    # 各フェーズの進捗を表示
    echo -e "\n${YELLOW}企画段階${NC}    $(show_progress_bar $(echo "$progress_json" | grep -o '"planning": [0-9]*' | grep -o '[0-9]*'))"
    echo -e "${YELLOW}プロット${NC}    $(show_progress_bar $(echo "$progress_json" | grep -o '"plotting": [0-9]*' | grep -o '[0-9]*'))"
    echo -e "${YELLOW}執筆${NC}        $(show_progress_bar $(echo "$progress_json" | grep -o '"writing": [0-9]*' | grep -o '[0-9]*'))"
    echo -e "${YELLOW}編集${NC}        $(show_progress_bar $(echo "$progress_json" | grep -o '"editing": [0-9]*' | grep -o '[0-9]*'))"
    echo -e "${YELLOW}校正${NC}        $(show_progress_bar $(echo "$progress_json" | grep -o '"proofing": [0-9]*' | grep -o '[0-9]*'))"
    
    # 現在のフェーズ
    local current_phase=$(echo "$progress_json" | grep -o '"current_phase": "[^"]*' | cut -d'"' -f4)
    echo -e "\n${BLUE}現在のフェーズ:${NC} ${GREEN}$current_phase${NC}"
    
    # 最終更新日時
    local updated=$(echo "$progress_json" | grep -o '"updated": "[^"]*' | cut -d'"' -f4)
    echo -e "${BLUE}最終更新:${NC} $updated"
    
    # 原稿の統計情報
    echo -e "\n${PURPLE}📝 原稿統計${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 最新の原稿を探す
    local latest_draft=$(ls -t "$BASE_DIR/stories/drafts/"*.md 2>/dev/null | head -1)
    local latest_revision=$(ls -t "$BASE_DIR/stories/revisions/"*.md 2>/dev/null | head -1)
    local latest_final=$(ls -t "$BASE_DIR/stories/final/"*.md 2>/dev/null | head -1)
    
    if [[ -f "$latest_draft" ]]; then
        local word_count=$(wc -m < "$latest_draft")
        echo -e "最新下書き: $(basename "$latest_draft")"
        echo -e "文字数: ${GREEN}$word_count${NC} 文字"
    fi
    
    if [[ -f "$latest_revision" ]]; then
        echo -e "最新改稿: $(basename "$latest_revision")"
    fi
    
    if [[ -f "$latest_final" ]]; then
        echo -e "最終稿: $(basename "$latest_final")"
    fi
}

# タイムライン表示
show_timeline() {
    echo -e "${PURPLE}📅 執筆タイムライン${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # ログファイルから履歴を取得
    if [[ -f "$BASE_DIR/logs/progress.log" ]]; then
        tail -20 "$BASE_DIR/logs/progress.log" | while read line; do
            echo -e "${BLUE}$line${NC}"
        done
    else
        echo "履歴がありません"
    fi
}

# 進捗を更新
update_progress() {
    local phase="$1"
    local percent="$2"
    
    # 有効なフェーズかチェック
    case "$phase" in
        planning|plotting|writing|editing|proofing)
            ;;
        *)
            echo -e "${RED}エラー: 無効なフェーズ '$phase'${NC}"
            exit 1
            ;;
    esac
    
    # パーセンテージの妥当性チェック
    if [[ ! "$percent" =~ ^[0-9]+$ ]] || [[ "$percent" -lt 0 ]] || [[ "$percent" -gt 100 ]]; then
        echo -e "${RED}エラー: パーセンテージは0-100の数値を指定してください${NC}"
        exit 1
    fi
    
    # 進捗ファイルを更新
    local progress_file="$BASE_DIR/tmp/progress.json"
    local temp_file="$BASE_DIR/tmp/progress_temp.json"
    
    # 既存のデータを読み込んで更新
    if [[ -f "$progress_file" ]]; then
        # sedを使って該当フェーズの値を更新
        sed "s/\"$phase\": [0-9]*/\"$phase\": $percent/" "$progress_file" > "$temp_file"
        sed -i '' "s/\"current_phase\": \"[^\"]*\"/\"current_phase\": \"$phase\"/" "$temp_file"
        sed -i '' "s/\"updated\": \"[^\"]*\"/\"updated\": \"$(date +%Y-%m-%d\ %H:%M:%S)\"/" "$temp_file"
        mv "$temp_file" "$progress_file"
    fi
    
    # ログに記録
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $phase: $percent% 完了" >> "$BASE_DIR/logs/progress.log"
    
    echo -e "${GREEN}✓ 進捗を更新しました${NC}"
    echo -e "  フェーズ: ${BLUE}$phase${NC}"
    echo -e "  進捗: ${BLUE}$percent%${NC}"
    
    # 自動的に次のフェーズに移行
    if [[ "$percent" -eq 100 ]]; then
        local next_phase=""
        case "$phase" in
            planning) next_phase="plotting" ;;
            plotting) next_phase="writing" ;;
            writing) next_phase="editing" ;;
            editing) next_phase="proofing" ;;
            proofing) 
                echo -e "${GREEN}🎉 物語が完成しました！${NC}"
                ;;
        esac
        
        if [[ -n "$next_phase" ]]; then
            echo -e "${YELLOW}→ 次のフェーズ: $next_phase${NC}"
        fi
    fi
}

# 詳細レポート生成
generate_report() {
    local report_date=$(date +%Y-%m-%d)
    
    cat << EOF
# 物語執筆進捗レポート
生成日: $report_date

## 📊 進捗概要

$(show_current_status | sed 's/\x1b\[[0-9;]*m//g')

## 📈 進捗履歴

\`\`\`
$(tail -50 "$BASE_DIR/logs/progress.log" 2>/dev/null || echo "履歴なし")
\`\`\`

## 📁 ファイル構成

### 下書き (drafts/)
$(ls -la "$BASE_DIR/stories/drafts/"*.md 2>/dev/null | awk '{print "- " $9 " (" $5 " bytes)"}' || echo "- なし")

### 改稿 (revisions/)
$(ls -la "$BASE_DIR/stories/revisions/"*.md 2>/dev/null | awk '{print "- " $9 " (" $5 " bytes)"}' || echo "- なし")

### 最終稿 (final/)
$(ls -la "$BASE_DIR/stories/final/"*.md 2>/dev/null | awk '{print "- " $9 " (" $5 " bytes)"}' || echo "- なし")

## 📝 メモ・設定

### プロット
$(ls -la "$BASE_DIR/plots/"*.md 2>/dev/null | awk '{print "- " $9}' || echo "- なし")

### キャラクター・世界観
$(ls -la "$BASE_DIR/notes/"*.md 2>/dev/null | awk '{print "- " $9}' || echo "- なし")

## 🔍 品質チェック

- [ ] テーマの一貫性
- [ ] キャラクターの魅力
- [ ] プロットの完成度
- [ ] 文章のリズム
- [ ] 誤字脱字チェック

---
Generated by Story Status Tool
EOF
}

# エージェント別の作業状況を表示
show_agent_status() {
    echo -e "${PURPLE}👥 エージェント作業状況${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 各エージェントの最終作業を確認
    local agents=("editor-in-chief" "editor" "writer" "copy-editor" "proofreader")
    local roles=("編集長" "編集者" "ライター" "敏腕編集者" "校正者")
    
    for i in "${!agents[@]}"; do
        local agent="${agents[$i]}"
        local role="${roles[$i]}"
        local status="待機中"
        local color=$YELLOW
        
        # ログから最新の作業を検索
        if [[ -f "$BASE_DIR/logs/communication_log.txt" ]]; then
            if grep -q "$agent" "$BASE_DIR/logs/communication_log.txt"; then
                status="作業済"
                color=$GREEN
            fi
        fi
        
        echo -e "${BLUE}$role${NC} ($agent): ${color}$status${NC}"
    done
}

# メイン処理
case "$1" in
    --current)
        show_current_status
        echo ""
        show_agent_status
        ;;
    --timeline)
        show_timeline
        ;;
    --update)
        update_progress "$2" "$3"
        ;;
    --report)
        generate_report
        ;;
    *)
        show_usage
        exit 1
        ;;
esac