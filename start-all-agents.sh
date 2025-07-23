#!/bin/bash
# start-all-agents.sh - 全エージェントを一括起動

echo "Starting all agents..."

# PRESIDENTを起動
echo "Starting PRESIDENT..."
./start-agents.sh president president

# 少し待つ
sleep 2

# マルチエージェントを起動
echo "Starting boss1..."
./start-agents.sh boss1 multiagent
sleep 1

echo "Starting worker1..."
./start-agents.sh worker1 multiagent
sleep 1

echo "Starting worker2..."
./start-agents.sh worker2 multiagent
sleep 1

echo "Starting worker3..."
./start-agents.sh worker3 multiagent

echo "All agents started!"
echo ""
echo "To view sessions:"
echo "  PRESIDENT: tmux attach-session -t president"
echo "  Team: tmux attach-session -t multiagent"
