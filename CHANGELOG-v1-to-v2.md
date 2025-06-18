# CHANGELOG: v1 → v2

## 🆕 新機能追加

### プロジェクトディレクトリ指定機能
- **setup-v2.sh**: プロジェクトディレクトリを引数で指定可能
- **agent-send-v2.sh**: プロジェクトディレクトリ情報の表示機能
- **tmp/project_config.txt**: プロジェクトディレクトリ情報の永続化

### ステータス確認機能
- **agent-send-v2.sh --status**: システム状態の可視化
- **agent-send-v2.sh --list**: エージェント一覧とプロジェクト情報表示

### 改善されたエラーハンドリング
- セッションが見つからない場合のヒント表示
- プロジェクトディレクトリの存在確認
- より詳細なエラーメッセージ

## 📁 ファイル構成

### v1ファイル（元のバージョン）
```
setup.sh              → setup-v1.sh
agent-send.sh         → agent-send-v1.sh
CLAUDE.md             → CLAUDE-v1.md
README.md             → README-v1.md
instructions/president.md → instructions/president-v1.md
instructions/boss.md   → instructions/boss-v1.md
instructions/worker.md → instructions/worker-v1.md
```

### v2ファイル（新バージョン）
```
setup-v2.sh           # プロジェクトディレクトリ指定機能付き
agent-send-v2.sh      # ステータス確認機能付き
CLAUDE-v2.md          # v2システム設定
README-v2.md          # v2使用方法説明
instructions/president-v2.md # プロジェクトディレクトリ対応
instructions/boss-v2.md      # プロジェクトディレクトリ対応
instructions/worker-v2.md    # プロジェクトディレクトリ対応
```

## 🔄 主な変更点

### setup.sh → setup-v2.sh
```diff
+ # 使用方法表示
+ show_usage() {
+     cat << EOF
+ 🤖 Multi-Agent Communication Demo 環境構築 v2
+ 
+ 使用方法:
+   $0 [プロジェクトディレクトリ]
+ EOF
+ }
+ 
+ # 引数処理
+ PROJECT_DIR=""
+ if [[ $# -eq 1 ]]; then
+     PROJECT_DIR="$1"
+     if [[ ! -d "$PROJECT_DIR" ]]; then
+         echo "❌ エラー: ディレクトリ '$PROJECT_DIR' が存在しません"
+         exit 1
+     fi
+ else
+     PROJECT_DIR="$(pwd)"
+ fi
+ 
- tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
+ tmux send-keys -t "multiagent:0.$i" "cd \"$PROJECT_DIR\"" C-m
+ 
+ # プロジェクトディレクトリ情報を保存
+ echo "$PROJECT_DIR" > ./tmp/project_config.txt
```

### agent-send.sh → agent-send-v2.sh
```diff
+ # 設定ファイル
+ CONFIG_FILE="./tmp/project_config.txt"
+ 
+ # プロジェクトディレクトリ情報を取得
+ get_project_info() {
+     if [[ -f "$CONFIG_FILE" ]]; then
+         local project_dir=$(head -n 1 "$CONFIG_FILE" 2>/dev/null)
+         if [[ -n "$project_dir" ]]; then
+             echo "📁 プロジェクトディレクトリ: $project_dir"
+         fi
+     fi
+ }
+ 
+ # ステータス表示
+ show_status() {
+     echo "🔍 システムステータス:"
+     echo "====================="
+     
+     # セッション確認
+     echo "📺 Tmux Sessions:"
+     if tmux has-session -t president 2>/dev/null; then
+         echo "  ✅ president: 実行中"
+     else
+         echo "  ❌ president: 停止中"
+     fi
+     
+     if tmux has-session -t multiagent 2>/dev/null; then
+         echo "  ✅ multiagent: 実行中"
+     else
+         echo "  ❌ multiagent: 停止中"
+     fi
+     
+     echo ""
+     get_project_info
+     
+     # ログファイル確認
+     if [[ -f "logs/send_log.txt" ]]; then
+         local log_lines=$(wc -l < logs/send_log.txt)
+         echo "📝 送信ログ: $log_lines 件のメッセージ"
+     else
+         echo "📝 送信ログ: なし"
+     fi
+ }
+ 
+ # --statusオプション
+ if [[ "$1" == "--status" ]]; then
+     show_status
+     exit 0
+ fi
```

### 指示書の変更
```diff
+ ## プロジェクトディレクトリについて
+ - あなたは指定されたプロジェクトディレクトリで作業しています
+ - このディレクトリには実際のプロジェクトファイルが存在します
+ - 生成されたコードはこのディレクトリに配置されます
+ 
+ ## ステータス確認
+ ```bash
+ # システム状態を確認
+ ./agent-send-v2.sh --status
+ ```
+ 
+ ## 作業フロー
+ 1. boss1からの指示を理解する
+ 2. プロジェクトディレクトリの構造を確認する
+ 3. 既存のファイルや設定を調査する
+ 4. 専門分野に応じた実装を行う
+ 5. 実装したコードをプロジェクトディレクトリに配置する
+ 6. boss1に完了報告をする
```

## 🎯 使用方法の違い

### v1（元の方法）
```bash
cd Claude-Code-Communication
./setup.sh
tmux attach-session -t president
```

### v2（推奨方法）
```bash
# 開発プロジェクトディレクトリに移動
cd /path/to/your/project

# Claude-Code-Communicationを配置
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication

# v2環境構築（プロジェクトディレクトリを指定）
./setup-v2.sh ..

# プロジェクトディレクトリに戻る
cd ..

# エージェント起動
tmux attach-session -t president
```

## 📊 機能比較

| 機能 | v1 | v2 |
|------|----|----|
| プロジェクトディレクトリ指定 | ❌ | ✅ |
| ステータス確認 | ❌ | ✅ |
| エラーハンドリング | 基本 | 改善 |
| 設定ファイル | ❌ | ✅ |
| プロジェクト情報表示 | ❌ | ✅ |
| 実用的な開発環境 | ❌ | ✅ |

## 🚀 移行ガイド

1. **v1ファイルの保存**: 既に完了
2. **v2ファイルの作成**: 既に完了
3. **テスト実行**: v2の動作確認
4. **本格運用**: v2への移行

この変更により、より実用的で安定した開発環境が構築できるようになりました。 