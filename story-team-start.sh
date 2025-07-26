#!/bin/bash

# 📚 物語執筆チーム自動起動スクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 物語執筆チーム起動スクリプト${NC}"
echo ""

# Claude起動確認
echo -e "${YELLOW}Claude Codeが全てのセッションで起動していることを確認してください${NC}"
echo "起動していない場合は、以下のコマンドを実行:"
echo "  tmux send-keys -t president 'claude --dangerously-skip-permissions' C-m"
echo "  for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude --dangerously-skip-permissions' C-m; done"
echo ""
read -p "Claudeが起動していますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}先にClaudeを起動してください${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 役割を各エージェントに送信します...${NC}"

# 編集長（president）
echo -e "${BLUE}→ 編集長に役割を送信${NC}"
tmux send-keys -t president "あなたはeditor-in-chief（編集長）です。@instructions/editor-in-chief.md の内容に従って行動してください。" C-m

# 編集者（boss1）
echo -e "${BLUE}→ 編集者に役割を送信${NC}"
tmux send-keys -t multiagent:0.0 "あなたはeditor（編集者）です。@instructions/editor.md の内容に従って行動してください。" C-m

# ライター（worker1）
echo -e "${BLUE}→ ライターに役割を送信${NC}"
tmux send-keys -t multiagent:0.1 "あなたはwriter（天才ライター）です。@instructions/writer.md の内容に従って行動してください。" C-m

# 敏腕編集者（worker2）
echo -e "${BLUE}→ 敏腕編集者に役割を送信${NC}"
tmux send-keys -t multiagent:0.2 "あなたはcopy-editor（敏腕編集者）です。@instructions/copy-editor.md の内容に従って行動してください。" C-m

# 校正者（worker3）
echo -e "${BLUE}→ 校正者に役割を送信${NC}"
tmux send-keys -t multiagent:0.3 "あなたはproofreader（校正者）です。@instructions/proofreader.md の内容に従って行動してください。" C-m

echo ""
echo -e "${GREEN}✅ 物語執筆チームの準備が完了しました！${NC}"
echo ""
echo -e "${YELLOW}📝 次のステップ:${NC}"
echo "1. 編集長に企画を依頼:"
echo "   ./agent-send-story.sh editor-in-chief \"短編小説を企画してください。テーマは『時を超えた約束』です。\""
echo ""
echo "2. 進捗確認:"
echo "   ./story-status.sh --current"
echo ""
echo "3. バージョン管理:"
echo "   ./story-version.sh list"
echo ""
echo -e "${BLUE}素晴らしい物語が生まれることを楽しみにしています！${NC}"