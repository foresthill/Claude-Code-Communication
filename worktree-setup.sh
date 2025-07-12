#!/bin/bash

# 🚀 Git Worktree セットアップスクリプト v3

set -e

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# 使用方法
show_usage() {
    cat << EOF
🌳 Git Worktree セットアップ

使用方法:
  $0 [プロジェクトディレクトリ] [機能名]

例:
  $0 /path/to/project emotion-tracker
  $0 . new-feature

説明:
  各workerに独立したGit Worktreeを作成し、並行開発を可能にします
EOF
}

# Gitリポジトリ確認
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Gitリポジトリではありません"
        exit 1
    fi
}

# developブランチ確認・作成
ensure_develop_branch() {
    if ! git show-ref --verify --quiet refs/heads/develop; then
        log_info "developブランチを作成します"
        git checkout -b develop main || git checkout -b develop master
    fi
}

# workerのworktree作成
create_worker_worktree() {
    local worker_num=$1
    local feature_name=$2
    local branch_name="worker${worker_num}/${feature_name}"
    local worktree_path=".worktrees/worker${worker_num}-${feature_name}"
    
    log_info "Worker${worker_num}のWorktree作成中..."
    
    # 既存のworktreeチェック
    if [ -d "$worktree_path" ]; then
        log_error "$worktree_path は既に存在します"
        return 1
    fi
    
    # ブランチ作成（developから）
    git branch "$branch_name" develop 2>/dev/null || {
        log_info "ブランチ $branch_name は既に存在します"
    }
    
    # Worktree作成
    git worktree add "$worktree_path" "$branch_name"
    
    # Worker用の設定ファイル作成
    cat > "$worktree_path/.worker-config" << EOL
WORKER_NUM=$worker_num
FEATURE_NAME=$feature_name
BRANCH_NAME=$branch_name
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
EOL
    
    log_success "Worker${worker_num}のWorktree作成完了: $worktree_path"
    
    # tmuxペインでディレクトリ変更
    if tmux has-session -t multiagent 2>/dev/null; then
        local pane_index=$((worker_num - 1))
        tmux send-keys -t "multiagent:0.$pane_index" "cd $(pwd)/$worktree_path" C-m
        tmux send-keys -t "multiagent:0.$pane_index" "echo '📁 Worktree: $worktree_path'" C-m
        tmux send-keys -t "multiagent:0.$pane_index" "echo '🌿 Branch: $branch_name'" C-m
    fi
}

# メイン処理
main() {
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local project_dir="$1"
    local feature_name="$2"
    
    # プロジェクトディレクトリに移動
    cd "$project_dir"
    
    # Git確認
    check_git_repo
    
    # developブランチ確保
    ensure_develop_branch
    
    echo "🌳 Git Worktree セットアップ開始"
    echo "================================="
    echo "📁 プロジェクト: $(pwd)"
    echo "✨ 機能名: $feature_name"
    echo ""
    
    # .worktreesディレクトリ作成
    mkdir -p .worktrees
    
    # 各workerのworktree作成
    for i in {1..3}; do
        create_worker_worktree $i "$feature_name" || {
            log_error "Worker${i}のWorktree作成に失敗しました"
        }
    done
    
    echo ""
    log_success "🎉 全Worktreeのセットアップ完了！"
    echo ""
    echo "📋 次のステップ:"
    echo "  1. 各workerが自分のworktreeで開発"
    echo "  2. 完了後、worktree-merge.sh でマージ"
    echo ""
    echo "💡 Worktree一覧:"
    git worktree list
}

main "$@"
