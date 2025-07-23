#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築 v3
# Git Worktree対応版

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

# 使用方法表示
show_usage() {
    cat << EOF
🤖 Multi-Agent Communication Demo 環境構築 v3

使用方法:
  $0 [プロジェクトディレクトリ]

例:
  $0 /path/to/your/project    # 指定したプロジェクトディレクトリで実行
  $0                          # 現在のディレクトリで実行

説明:
  - Git Worktree対応の並行開発環境を構築
  - 各workerが独立したブランチで作業可能
EOF
}

# 引数処理
PROJECT_DIR=""
if [[ $# -eq 1 ]]; then
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    PROJECT_DIR="$1"
    if [[ ! -d "$PROJECT_DIR" ]]; then
        echo "❌ エラー: ディレクトリ '$PROJECT_DIR' が存在しません"
        exit 1
    fi
    log_info "プロジェクトディレクトリ: $PROJECT_DIR"
else
    PROJECT_DIR="$(pwd)"
    log_info "現在のディレクトリを使用: $PROJECT_DIR"
fi

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🤖 Multi-Agent Communication Demo 環境構築 v3"
echo "============================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

# プロジェクトディレクトリ情報を保存
echo "$PROJECT_DIR" > ./tmp/project_config.txt
log_info "プロジェクトディレクトリ情報を保存: $PROJECT_DIR"

# STEP 1.5: プロジェクトディレクトリに指示書のシンボリックリンクを作成
if [ "$PROJECT_DIR" != "$SCRIPT_DIR" ]; then
    log_info "📄 指示書のシンボリックリンクを作成中..."
    
    # .claude/organizationディレクトリ作成
    mkdir -p "$PROJECT_DIR/.claude/organization"
    
    # instructionsディレクトリへのシンボリックリンク作成
    if [ ! -e "$PROJECT_DIR/.claude/organization/instructions" ]; then
        ln -sf "$SCRIPT_DIR/instructions" "$PROJECT_DIR/.claude/organization/instructions"
        log_success "指示書のリンク作成完了: .claude/organization/instructions"
    else
        log_info "指示書のリンクは既に存在します"
    fi
fi

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：boss1 + worker1,2,3）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s multiagent -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
tmux select-pane -t "multiagent:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "multiagent:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("boss1" "worker1" "worker2" "worker3")

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
    
    # まずClaude-Code-CommunicationディレクトリでCLAUDE.mdを表示
    tmux send-keys -t "multiagent:0.$i" "cd \"$SCRIPT_DIR\" && cat CLAUDE.md" C-m
    
    # その後、作業ディレクトリをプロジェクトディレクトリに設定
    tmux send-keys -t "multiagent:0.$i" "cd \"$PROJECT_DIR\"" C-m
    
    # カラープロンプト設定
    if [ $i -eq 0 ]; then
        # boss1: 赤色
        tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    else
        # workers: 青色
        tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    fi
    
    # ウェルカムメッセージ
    tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント (v3 Worktree対応) ==='" C-m
    tmux send-keys -t "multiagent:0.$i" "echo '作業ディレクトリ: $PROJECT_DIR'" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（1ペイン）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s president

# まずClaude-Code-CommunicationディレクトリでCLAUDE.mdを表示
tmux send-keys -t president "cd \"$SCRIPT_DIR\" && cat CLAUDE.md" C-m

# その後、作業ディレクトリをプロジェクトディレクトリに設定
tmux send-keys -t president "cd \"$PROJECT_DIR\"" C-m

tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t president "echo '=== PRESIDENT セッション (v3) ==='" C-m
tmux send-keys -t president "echo 'プロジェクト統括責任者'" C-m
tmux send-keys -t president "echo '作業ディレクトリ: $PROJECT_DIR'" C-m
tmux send-keys -t president "echo '========================'" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: boss1     (チームリーダー/PM)"
echo "    Pane 1: worker1   (実行担当者A)"
echo "    Pane 2: worker2   (実行担当者B)"
echo "    Pane 3: worker3   (実行担当者C)"
echo ""
echo "  presidentセッション（1ペイン）:"
echo "    Pane 0: PRESIDENT (プロジェクト統括)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🌳 Git Worktree作成:"
echo "     ./worktree-setup.sh $PROJECT_DIR [機能名]"
echo ""
echo "  2. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # マルチエージェント確認"
echo "     tmux attach-session -t president    # プレジデント確認"
echo ""
echo "  3. 🤖 Claude Code起動:"
echo "     方法1（推奨・権限スキップ）: ./start-all-agents-quick.sh"
echo "     方法2（通常）: ./start-all-agents.sh"
echo "     方法3: 各セッションでclaude起動後、以下を入力:"
echo "            「あなたは[役割]です。@.claude/organization/instructions/[ファイル].md の内容に従って行動してください。」"
echo ""
echo "  4. 📜 指示書確認:"
echo "     PRESIDENT: .claude/organization/instructions/president.md"
echo "     boss1: .claude/organization/instructions/boss.md (PM機能付き)"
echo "     worker1,2,3: .claude/organization/instructions/worker.md (Worktree対応)"
echo "     システム構造: CLAUDE.md"
echo ""
echo "  5. 🎯 開発開始: PRESIDENTに指示を入力"
echo ""
echo "📁 作業ディレクトリ: $PROJECT_DIR"
echo ""
echo "💡 v3新機能:"
echo "   - Git Worktree統合"
echo "   - 並行開発サポート"
echo "   - 自動マージ機能"
echo "   - ビルド検証" 