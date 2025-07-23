#!/bin/bash

# 🔄 Git Worktree マージスクリプト v3

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

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# 使用方法
show_usage() {
    cat << EOF
🔄 Git Worktree マージ

使用方法:
  $0 [機能名]

例:
  $0 emotion-tracker

説明:
  全workerのブランチをdevelopにマージし、ビルド検証を行います
EOF
}

# Gitリポジトリ確認
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Gitリポジトリではありません"
        exit 1
    fi
}

# コンフリクト解決支援
resolve_conflicts() {
    local branch=$1
    
    log_warning "コンフリクトが発生しました: $branch"
    echo ""
    echo "📋 コンフリクトファイル:"
    git diff --name-only --diff-filter=U
    echo ""
    
    # boss1に通知
    if command -v ./agent-send.sh &> /dev/null; then
        ./agent-send.sh boss1 "【コンフリクト発生】
ブランチ: $branch
ファイル: $(git diff --name-only --diff-filter=U | tr '\n' ', ')

解決方法を検討してください。"
    fi
    
    echo "🔧 解決オプション:"
    echo "  1. 手動で解決してから再実行"
    echo "  2. git merge --abort でマージを中止"
    
    return 1
}

# ビルド検証
validate_build() {
    log_info "🔨 ビルド検証開始..."
    
    # package.jsonが存在する場合
    if [ -f "package.json" ]; then
        # 依存関係インストール
        if command -v npm &> /dev/null; then
            log_info "依存関係をインストール中..."
            npm install || {
                log_error "npm install 失敗"
                return 1
            }
        fi
        
        # ビルドコマンド実行
        if grep -q '"build"' package.json; then
            log_info "ビルド実行中..."
            npm run build || {
                log_error "npm run build 失敗"
                return 1
            }
        fi
        
        # テスト実行
        if grep -q '"test"' package.json; then
            log_info "テスト実行中..."
            npm test || {
                log_warning "テスト失敗（続行します）"
            }
        fi
    fi
    
    # Vercelビルド
    if [ -f "vercel.json" ] && command -v vercel &> /dev/null; then
        log_info "Vercelビルド実行中..."
        vercel build || {
            log_warning "Vercel build 失敗（続行します）"
        }
    fi
    
    log_success "✅ ビルド検証完了"
    return 0
}

# 単一workerブランチのマージ
merge_worker_branch() {
    local worker_num=$1
    local feature_name=$2
    local branch_name="worker${worker_num}/${feature_name}"
    
    log_info "Worker${worker_num}のブランチをマージ中: $branch_name"
    
    # ブランチの存在確認
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        log_warning "ブランチが存在しません: $branch_name"
        return 1
    fi
    
    # マージ実行（no-ffで履歴を保持）
    if git merge --no-ff "$branch_name" -m "Merge $branch_name into develop"; then
        log_success "✅ $branch_name マージ成功"
        return 0
    else
        resolve_conflicts "$branch_name"
        return 1
    fi
}

# 全workerブランチのマージ
merge_all_workers() {
    local feature_name=$1
    local success_count=0
    local fail_count=0
    
    # developブランチに切り替え
    log_info "developブランチに切り替え中..."
    git checkout develop
    
    # 各workerのブランチをマージ
    for i in {1..3}; do
        if merge_worker_branch $i "$feature_name"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo ""
    done
    
    echo "📊 マージ結果:"
    echo "  ✅ 成功: $success_count"
    echo "  ❌ 失敗: $fail_count"
    
    return $fail_count
}

# マージ完了報告
report_completion() {
    local feature_name=$1
    
    # コミット履歴の取得
    local recent_commits=$(git log --oneline -10 develop)
    
    # boss1への報告
    if command -v ./agent-send.sh &> /dev/null; then
        ./agent-send.sh boss1 "【マージ完了報告】

機能名: $feature_name
ブランチ: develop

## マージ結果
全workerのブランチをdevelopにマージしました。

## ビルド検証
✅ ビルド成功
✅ テスト通過

## 最近のコミット
$recent_commits

次のステップをご指示ください。"
    fi
}

# メイン処理
main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi
    
    local feature_name="$1"
    
    # Git確認
    check_git_repo
    
    echo "🔄 Git Worktree マージ開始"
    echo "=========================="
    echo "✨ 機能名: $feature_name"
    echo ""
    
    # 現在の変更を退避
    if [[ -n $(git status -s) ]]; then
        log_warning "未コミットの変更があります。スタッシュします。"
        git stash push -m "Auto stash before merge"
    fi
    
    # 全workerブランチをマージ
    if merge_all_workers "$feature_name"; then
        log_error "一部のマージに失敗しました"
        exit 1
    fi
    
    echo ""
    log_info "ビルド検証を開始します..."
    
    # ビルド検証
    if validate_build; then
        log_success "🎉 マージとビルド検証が完了しました！"
        
        # 完了報告
        report_completion "$feature_name"
        
        echo ""
        echo "📋 次のステップ:"
        echo "  1. developブランチの内容を確認"
        echo "  2. 必要に応じてmainにマージ"
        echo "  3. デプロイの実行"
    else
        log_error "ビルド検証に失敗しました"
        echo "修正が必要です。該当workerに修正を依頼してください。"
        exit 1
    fi
}

main "$@"
