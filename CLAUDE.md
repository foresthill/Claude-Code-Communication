# Agent Communication System

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー
- **worker1,2,3** (multiagent:0.1-3): 実行担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT 

## 🆕 v2新機能

### プロジェクトディレクトリ指定
- エージェントは指定されたプロジェクトディレクトリで作業
- 実際のプロジェクトファイルにアクセス可能
- 生成されたコードが適切な場所に配置される

### ステータス確認
```bash
./agent-send-v2.sh --status    # システム状態確認
./agent-send-v2.sh --list      # エージェント一覧表示
```

### 設定ファイル
- `tmp/project_config.txt`: プロジェクトディレクトリ情報を保存
- システム状態の永続化

## 📁 作業ディレクトリ
エージェントは `tmp/project_config.txt` に保存されたプロジェクトディレクトリで作業します。

## 🔧 環境構築
```bash
./setup.sh [プロジェクトディレクトリ]      # 基本版
./setup-v2.sh [プロジェクトディレクトリ]    # v2版（推奨）
```

例：
```bash
./setup-v2.sh /path/to/your/project    # 指定したプロジェクトディレクトリで実行
./setup-v2.sh                          # 現在のディレクトリで実行
```

## 💡 推奨使用方法
1. 開発プロジェクトディレクトリに移動
2. Claude-Code-Communicationをサブディレクトリとして配置
3. `./setup-v2.sh ..` で環境構築
4. プロジェクトディレクトリに戻ってエージェント起動

これにより、エージェントが実際のプロジェクトファイルにアクセスでき、より実用的な開発が可能になります。 