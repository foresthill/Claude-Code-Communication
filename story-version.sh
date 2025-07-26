#!/bin/bash

# 📚 物語バージョン管理スクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ベースディレクトリ
STORY_DIR=".claude/organization/stories"
DRAFTS_DIR="$STORY_DIR/drafts"
REVISIONS_DIR="$STORY_DIR/revisions"
FINAL_DIR="$STORY_DIR/final"

# 使用方法を表示
show_usage() {
    cat << EOF
📚 物語バージョン管理ツール

使用方法:
  $0 save <ファイル名> [説明]    - 新しいバージョンを保存
  $0 list                        - バージョン一覧を表示
  $0 diff <v1> <v2>             - バージョン間の差分を表示
  $0 restore <バージョン>        - 特定バージョンを復元
  $0 backup                      - 現在の全ファイルをバックアップ

例:
  $0 save story.md "第1章完成"
  $0 diff story_v1.md story_v2.md
  $0 restore story_v1.md
EOF
}

# バージョン番号を取得
get_next_version() {
    local base_name="$1"
    local dir="$2"
    local max_version=0
    
    for file in "$dir"/*_v*.md; do
        if [[ -f "$file" ]]; then
            version=$(echo "$file" | sed -n 's/.*_v\([0-9]\+\)_.*/\1/p')
            if [[ -n "$version" && "$version" -gt "$max_version" ]]; then
                max_version=$version
            fi
        fi
    done
    
    echo $((max_version + 1))
}

# ファイルを保存
save_version() {
    local source_file="$1"
    local description="${2:-"no description"}"
    
    if [[ ! -f "$source_file" ]]; then
        echo -e "${RED}エラー: ファイル '$source_file' が見つかりません${NC}"
        exit 1
    fi
    
    # ファイル名から拡張子を除去
    local base_name=$(basename "$source_file" .md)
    
    # 保存先ディレクトリを決定
    local target_dir="$DRAFTS_DIR"
    if [[ "$source_file" == *"edited"* ]]; then
        target_dir="$REVISIONS_DIR"
    elif [[ "$source_file" == *"final"* || "$source_file" == *"proofread"* ]]; then
        target_dir="$FINAL_DIR"
    fi
    
    # 次のバージョン番号を取得
    local version=$(get_next_version "$base_name" "$target_dir")
    
    # タイムスタンプ
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # 新しいファイル名
    local new_file="${base_name}_v${version}_${timestamp}.md"
    local target_path="$target_dir/$new_file"
    
    # ファイルをコピー
    cp "$source_file" "$target_path"
    
    # メタデータを記録
    cat >> ".claude/organization/logs/version_history.log" << EOF
[$(date '+%Y-%m-%d %H:%M:%S')] SAVE
File: $new_file
Source: $source_file
Description: $description
Directory: $target_dir
EOF
    
    echo -e "${GREEN}✓ バージョン保存完了${NC}"
    echo -e "  ファイル: ${BLUE}$new_file${NC}"
    echo -e "  保存先: $target_dir"
    echo -e "  説明: $description"
}

# バージョン一覧を表示
list_versions() {
    echo -e "${BLUE}📚 保存されているバージョン${NC}"
    echo ""
    
    for dir in "$DRAFTS_DIR" "$REVISIONS_DIR" "$FINAL_DIR"; do
        if [[ -d "$dir" ]]; then
            dir_name=$(basename "$dir")
            echo -e "${YELLOW}[$dir_name]${NC}"
            
            for file in "$dir"/*.md; do
                if [[ -f "$file" ]]; then
                    filename=$(basename "$file")
                    size=$(du -h "$file" | cut -f1)
                    date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1-2)
                    echo "  - $filename ($size, $date)"
                fi
            done
            echo ""
        fi
    done
}

# バージョン間の差分を表示
show_diff() {
    local file1="$1"
    local file2="$2"
    
    # ファイルを探す
    local path1=""
    local path2=""
    
    for dir in "$DRAFTS_DIR" "$REVISIONS_DIR" "$FINAL_DIR"; do
        [[ -f "$dir/$file1" ]] && path1="$dir/$file1"
        [[ -f "$dir/$file2" ]] && path2="$dir/$file2"
    done
    
    if [[ -z "$path1" ]]; then
        echo -e "${RED}エラー: ファイル '$file1' が見つかりません${NC}"
        exit 1
    fi
    
    if [[ -z "$path2" ]]; then
        echo -e "${RED}エラー: ファイル '$file2' が見つかりません${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}差分: $file1 → $file2${NC}"
    echo ""
    
    # 文字数の比較
    chars1=$(wc -m < "$path1")
    chars2=$(wc -m < "$path2")
    diff_chars=$((chars2 - chars1))
    
    echo -e "文字数: $chars1 → $chars2 (${diff_chars:+}$diff_chars)"
    echo ""
    
    # 差分表示
    if command -v diff >/dev/null 2>&1; then
        diff -u "$path1" "$path2" | sed '1,2d' | head -50
        echo ""
        echo "[差分の続きがある場合は省略されています]"
    else
        echo "diffコマンドが利用できません"
    fi
}

# バージョンを復元
restore_version() {
    local version_file="$1"
    local found=""
    local source_path=""
    
    # ファイルを探す
    for dir in "$DRAFTS_DIR" "$REVISIONS_DIR" "$FINAL_DIR"; do
        if [[ -f "$dir/$version_file" ]]; then
            found="yes"
            source_path="$dir/$version_file"
            break
        fi
    done
    
    if [[ -z "$found" ]]; then
        echo -e "${RED}エラー: バージョン '$version_file' が見つかりません${NC}"
        exit 1
    fi
    
    # 復元先を決定
    local restore_name="restored_$(date +%Y%m%d_%H%M%S).md"
    cp "$source_path" "$restore_name"
    
    echo -e "${GREEN}✓ バージョン復元完了${NC}"
    echo -e "  元ファイル: ${BLUE}$version_file${NC}"
    echo -e "  復元先: ${BLUE}$restore_name${NC}"
    
    # ログに記録
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] RESTORE: $version_file → $restore_name" >> ".claude/organization/logs/version_history.log"
}

# 全ファイルをバックアップ
backup_all() {
    local backup_dir=".claude/organization/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    echo -e "${BLUE}📦 バックアップ開始...${NC}"
    
    # 各ディレクトリをコピー
    for dir in "stories" "plots" "notes"; do
        if [[ -d ".claude/organization/$dir" ]]; then
            cp -r ".claude/organization/$dir" "$backup_dir/"
            echo -e "  ${GREEN}✓${NC} $dir"
        fi
    done
    
    # バックアップ情報を記録
    cat > "$backup_dir/backup_info.txt" << EOF
バックアップ日時: $(date)
バックアップ元: .claude/organization/
ファイル数: $(find "$backup_dir" -type f -name "*.md" | wc -l)
合計サイズ: $(du -sh "$backup_dir" | cut -f1)
EOF
    
    echo -e "${GREEN}✓ バックアップ完了${NC}"
    echo -e "  保存先: ${BLUE}$backup_dir${NC}"
}

# メイン処理
case "$1" in
    save)
        save_version "$2" "$3"
        ;;
    list)
        list_versions
        ;;
    diff)
        show_diff "$2" "$3"
        ;;
    restore)
        restore_version "$2"
        ;;
    backup)
        backup_all
        ;;
    *)
        show_usage
        exit 1
        ;;
esac