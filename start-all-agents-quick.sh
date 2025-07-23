#!/bin/bash
# start-all-agents-quick.sh - 全エージェントを権限スキップで一括起動

echo "🚀 全エージェントを起動中..."

# PRESIDENTを起動（別セッション）
echo "Starting PRESIDENT..."
tmux send-keys -t president "claude --dangerously-skip-permissions" C-m
sleep 2
tmux send-keys -t president "あなたはpresidentです。@.claude/organization/instructions/president.md の内容に従って行動してください。" C-m

# マルチエージェントを起動（4ペイン）
echo "Starting multiagent team..."
for i in {0..3}; do
    case $i in
        0) ROLE="boss1" FILE="boss.md" ;;
        1) ROLE="worker1" FILE="worker.md" ;;
        2) ROLE="worker2" FILE="worker.md" ;;
        3) ROLE="worker3" FILE="worker.md" ;;
    esac
    
    echo "Starting $ROLE..."
    tmux send-keys -t multiagent:0.$i "claude --dangerously-skip-permissions" C-m
    sleep 1
    tmux send-keys -t multiagent:0.$i "あなたは${ROLE}です。@.claude/organization/instructions/${FILE} の内容に従って行動してください。" C-m
    sleep 1
done

echo ""
echo "✅ 全エージェント起動完了！"
echo ""
echo "📺 セッションを確認："
echo "  - PRESIDENT: tmux attach-session -t president"
echo "  - Team: tmux attach-session -t multiagent"
echo ""
echo "💡 ヒント: Ctrl+b, 数字 でペイン切り替え"
