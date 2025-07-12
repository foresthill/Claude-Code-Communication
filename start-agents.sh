#!/bin/bash
# start-agents.sh - エージェントを適切な指示と共に起動

ROLE=$1
SESSION=$2

if [ -z "$ROLE" ] || [ -z "$SESSION" ]; then
    echo "Usage: ./start-agents.sh [role] [session]"
    echo "Roles: president, boss1, worker1, worker2, worker3"
    echo "Sessions: president, multiagent"
    exit 1
fi

# 指示ファイルのパスを設定
INSTRUCTION_FILE=""
case $ROLE in
    president)
        INSTRUCTION_FILE="instructions/president.md"
        ;;
    boss1)
        INSTRUCTION_FILE="instructions/boss.md"
        ;;
    worker*)
        INSTRUCTION_FILE="instructions/worker.md"
        ;;
    *)
        echo "Unknown role: $ROLE"
        exit 1
        ;;
esac

# Claudeを起動して最初のメッセージを送信
if [ "$SESSION" = "president" ]; then
    tmux send-keys -t president "claude" C-m
    sleep 2
    tmux send-keys -t president "あなたは${ROLE}です。以下のファイルの内容に従って行動してください：@${INSTRUCTION_FILE}" C-m
else
    # multiagentセッションの場合、ペイン番号を計算
    case $ROLE in
        boss1) PANE=0 ;;
        worker1) PANE=1 ;;
        worker2) PANE=2 ;;
        worker3) PANE=3 ;;
    esac
    tmux send-keys -t multiagent:0.$PANE "claude" C-m
    sleep 2
    tmux send-keys -t multiagent:0.$PANE "あなたは${ROLE}です。以下のファイルの内容に従って行動してください：@${INSTRUCTION_FILE}" C-m
fi
