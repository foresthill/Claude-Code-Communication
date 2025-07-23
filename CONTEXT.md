# Claude-Code-Communication 修正作業の文脈

## 📅 修正日時
2024年12月19日（初回）
2025年7月12日（ファイル配置ルール追加）

## 🎯 修正の目的
- **エージェントが指定したプロジェクトディレクトリで作業する**
- **スクリプトやログは共通ディレクトリ（Claude-Code-Communication）で一元管理**
- **ハードコーディングされたパスを削除し、環境非依存にする**
- **プロジェクトルートをクリーンに保つためのファイル配置ルール確立**

## 🔧 修正したファイル

### 2025年7月12日の修正
1. **FILE_PLACEMENT_GUIDE.md** - ファイル配置ガイドラインを作成
2. **instructions/boss.md** - ファイル配置ルールを追加
3. **instructions/worker.md** - ファイル配置ルールを追加
4. **scripts/file-placement-helper.sh** - ファイル配置ヘルパースクリプトを作成

### 2024年12月19日の修正

### 1. setup.sh
- `SCRIPT_DIR`変数を追加してスクリプトのディレクトリを取得
- 各ペインで`CLAUDE.md`を表示する際に`$SCRIPT_DIR`を使用
- その後、プロジェクトディレクトリに移動

### 2. setup-v2.sh
- 同様に`SCRIPT_DIR`変数を追加
- 各ペインで`CLAUDE-v2.md`を表示する際に`$SCRIPT_DIR`を使用
- 指示書の参照もv2版に更新

### 3. agent-send.sh
- `SCRIPT_DIR`変数を追加
- 設定ファイルとログファイルのパスを`$SCRIPT_DIR`を使用するように修正

### 4. agent-send-v2.sh
- 同様に`SCRIPT_DIR`変数を追加
- 設定ファイルとログファイルのパスを`$SCRIPT_DIR`を使用するように修正

### 5. CLAUDE.md
- v2の機能についても記載
- プロジェクトディレクトリ指定機能の説明を追加

### 6. README.md
- v2の機能について詳しく記載
- プロジェクトディレクトリ指定機能の使用方法を追加
- トラブルシューティングセクションを追加

## 💡 主な改善点

### 2025年7月12日の改善
1. **ファイル配置ルールの確立**
   - プロジェクトルートをクリーンに保つ
   - レポート、ログ、一時ファイルの適切な配置場所を定義
   - エージェントが自動的に正しい場所にファイルを作成

2. **ファイル配置ヘルパーの提供**
   ```bash
   # ヘルパー関数で適切な場所に配置
   place_file "report" "analysis.md" "内容"
   ```

### 2024年12月19日の改善

### 1. パス非依存
```bash
# 修正前（ハードコーディング）
cd /c/Users/Naoya\ Morioka/AI-Driven/Claude-Code-Communication && cat CLAUDE.md

# 修正後（動的取得）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" && cat CLAUDE.md
```

### 2. 作業ディレクトリの分離
- **エージェントの作業**: 指定したプロジェクトディレクトリ
- **スクリプト・ログ**: Claude-Code-Communicationディレクトリ

### 3. 自動仕様書表示
- エージェント起動時に`CLAUDE.md`/`CLAUDE-v2.md`を自動表示
- 各エージェントが最新の仕様を確認できる

## 🎯 実現されたニーズ

### ユーザーの要望
> 「エージェントで呼び出されたClaude Codeが指定したプロジェクトディレクトリで作業してくれればよい。スクリプトやログはClaude-Code-Communicationに共通化して一本にしておきたい」

### 解決策
1. **エージェントの作業ディレクトリ**: プロジェクトディレクトリ（引数で指定）
2. **スクリプト・ログの場所**: Claude-Code-Communicationディレクトリ（一元管理）
3. **パス参照**: 動的取得で環境非依存

## 📋 使用方法

### 基本使用
```bash
# プロジェクトディレクトリで実行
./setup-v2.sh /path/to/your/project

# エージェント起動
tmux attach-session -t president
tmux attach-session -t multiagent

# メッセージ送信
./agent-send-v2.sh president "指示書に従って"
```

### 推奨構成
```
your-project/
├── src/
├── docs/
└── Claude-Code-Communication/  # サブディレクトリとして配置
    ├── setup-v2.sh
    ├── agent-send-v2.sh
    ├── CLAUDE-v2.md
    └── logs/
```

## 🔍 技術的な詳細

### SCRIPT_DIR変数の仕組み
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```
- `${BASH_SOURCE[0]}`: 現在実行中のスクリプトのパス
- `dirname`: ディレクトリ部分を取得
- `cd && pwd`: そのディレクトリに移動して絶対パスを取得

### ファイル参照の統一
```bash
# 設定ファイル
CONFIG_FILE="$SCRIPT_DIR/tmp/project_config.txt"

# ログファイル
mkdir -p "$SCRIPT_DIR/logs"
echo "..." >> "$SCRIPT_DIR/logs/send_log.txt"

# 仕様書表示
cd "$SCRIPT_DIR" && cat CLAUDE-v2.md
```

## 📝 今後の拡張可能性

1. **新しいエージェント追加**: `instructions/`ディレクトリに指示書を追加
2. **設定ファイル拡張**: `tmp/`ディレクトリに追加設定を保存
3. **ログ機能強化**: `logs/`ディレクトリに詳細ログを追加
4. **環境変数対応**: より柔軟な設定管理

## 🎉 結果

- ✅ 環境非依存の動作
- ✅ プロジェクトディレクトリでの作業
- ✅ スクリプト・ログの一元管理
- ✅ 自動仕様書表示
- ✅ v2機能の統合
- ✅ ファイル配置ルールの確立（2025年7月12日追加）

この修正により、どの環境でも、どのプロジェクトでも、エージェントシステムが正しく動作し、プロジェクトルートがクリーンに保たれるようになりました。 