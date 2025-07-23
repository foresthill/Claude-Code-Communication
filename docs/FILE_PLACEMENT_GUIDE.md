# Claude Code Organization - ファイル配置ガイド

## 📁 ファイルの配置ルール

### 1. フレームワーク本体（Claude-Code-Communication-foresthill）
**場所**: `/Users/foresthill/Development/AI-Driven/Claude-Code-Communication-foresthill/`

**配置すべきファイル**:
- 汎用的なスクリプト（どのプロジェクトでも使える）
- フレームワークのドキュメント
- テンプレートファイル

```
Claude-Code-Communication-foresthill/
├── instructions/         # 汎用的な役割定義テンプレート
├── scripts/             # 汎用スクリプト
│   └── auto-detect-project.sh
├── docs/                # フレームワークドキュメント
│   ├── CONTEXT_RECOVERY_GUIDE.md
│   └── worktree-integration.md
├── setup.sh             # 基本セットアップ
├── agent-send.sh        # 基本通信スクリプト
└── README.md            # フレームワークの説明
```

### 2. 開発先プロジェクト（例: jinja-log-ai）
**場所**: `/Users/foresthill/Development/AI-Driven/jinja-log-ai/`

**配置すべきファイル**:
- プロジェクト固有の設定
- カスタマイズされた役割定義
- プロジェクト専用スクリプト

```
jinja-log-ai/
├── .claude/
│   └── organization/
│       ├── roles/       # プロジェクト固有の役割定義
│       │   ├── president.md
│       │   ├── boss1.md
│       │   └── worker[1-3].md
│       ├── scripts/     # プロジェクト専用スクリプト
│       │   ├── setup.sh
│       │   ├── agent-send.sh
│       │   ├── start-all-agents.sh
│       │   └── recover-context.sh
│       ├── config.json  # プロジェクト設定
│       ├── PROJECT_CONTEXT.md  # プロジェクト情報
│       └── tmp/         # 一時ファイル
└── （アプリケーションコード）
```

## 🔧 セットアップ手順

### 新規プロジェクトでClaude Code Organizationを使う場合

1. **フレームワークをクローン**（初回のみ）
   ```bash
   git clone https://github.com/foresthill/Claude-Code-Communication.git
   ```

2. **プロジェクトディレクトリで初期化**
   ```bash
   cd /path/to/your-project
   
   # フレームワークからセットアップスクリプトを実行
   /path/to/Claude-Code-Communication-foresthill/setup.sh .
   ```

3. **プロジェクト固有の設定**
   ```bash
   # config.json を編集
   vi .claude/organization/config.json
   
   # 役割定義をカスタマイズ
   vi .claude/organization/roles/*.md
   ```

## 💡 どこに何を置くか迷ったら

### フレームワーク側に置くもの
- ✅ 他のプロジェクトでも使える汎用的なもの
- ✅ フレームワークの使い方の説明
- ✅ テンプレートやサンプル

### プロジェクト側に置くもの
- ✅ そのプロジェクト専用の設定
- ✅ カスタマイズされたスクリプト
- ✅ プロジェクト固有の情報

## 🚨 よくある間違い

1. **間違い**: フレームワークのファイルを直接編集
   **正解**: プロジェクトにコピーしてから編集

2. **間違い**: プロジェクト固有の設定をフレームワークに保存
   **正解**: `.claude/organization/`以下に保存

3. **間違い**: セッション名をハードコード
   **正解**: `config.json`で管理

## 📝 実践例

### jinja-log-aiの場合
```bash
# 1. セットアップ（フレームワークから）
/Users/foresthill/Development/AI-Driven/Claude-Code-Communication-foresthill/setup.sh .

# 2. カスタマイズ（プロジェクト内で）
echo '{
  "project_name": "jinja-log-ai",
  "session_prefix": "jinja-",
  "sessions": {
    "multiagent": "jinja-multiagent",
    "president": "jinja-president"
  }
}' > .claude/organization/config.json

# 3. 使用（プロジェクト内のスクリプトで）
./.claude/organization/scripts/agent-send.sh boss1 "開発開始"
```

## まとめ

- **フレームワーク**: 汎用的な機能とドキュメント
- **プロジェクト**: 固有の設定とカスタマイズ
- **明確な分離**: 再利用性と保守性の向上
