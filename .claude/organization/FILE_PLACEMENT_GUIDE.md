# ファイル配置ガイドライン

## 概要
このドキュメントは、Claude Code Organizationプロジェクトにおけるファイルの適切な配置場所を定義します。

## 重要な原則
**プロジェクトルートには、システムファイル（README.md、CHANGELOG.md等）以外のファイルを配置しない**

## ファイル種別と配置場所

### 1. システムファイル（プロジェクトルートに配置可）
- `README.md` - プロジェクトの説明
- `CHANGELOG.md` - 変更履歴
- `CHANGELOG.ja.md` - 日本語版変更履歴
- `CLAUDE.md` - Claude関連の基本設定
- `CONTEXT.md` - プロジェクトコンテキスト
- `LICENSE` - ライセンス情報
- `.gitignore` - Git除外設定

### 2. レポート・分析ファイル
**配置場所**: `.claude/organization/reports/`

例：
- `query_boss1_git_status.md`
- `urgent_integration_investigation.md`
- `boss1_review_feature.md`
- `FINAL_QUALITY_REPORT.md`

### 3. エージェント間の通信ログ
**配置場所**: `.claude/organization/logs/`

例：
- `boss1_to_worker1_[日付].md`
- `worker1_completion_[日付].md`
- `president_review_[日付].md`

### 4. 作業中の一時ファイル
**配置場所**: `.claude/organization/tmp/`

例：
- `draft_feature_plan.md`
- `merge_conflict_notes.md`
- `build_error_log.md`

### 5. ドキュメント
**配置場所**: `docs/`

例：
- `architecture.md`
- `api_reference.md`
- `troubleshooting.md`

### 6. 設定ファイル
**配置場所**: `.claude/organization/`

例：
- `config.json`
- `settings.json`

## ディレクトリ構造の例

```
project-root/
├── README.md
├── CHANGELOG.md
├── CLAUDE.md
├── CONTEXT.md
├── .claude/
│   └── organization/
│       ├── reports/         # レポート・分析結果
│       │   ├── query_boss1_git_status.md
│       │   ├── urgent_integration_investigation.md
│       │   └── FINAL_QUALITY_REPORT.md
│       ├── logs/           # 通信ログ
│       │   └── 2025-07-12_boss1_worker1.md
│       ├── tmp/            # 一時ファイル
│       │   └── draft_plan.md
│       └── config.json     # 設定ファイル
├── docs/                   # プロジェクトドキュメント
│   ├── FILE_PLACEMENT_GUIDE.md
│   └── worktree-integration.md
└── instructions/           # エージェント指示書
    ├── boss.md
    ├── president.md
    └── worker.md
```

## エージェントへの指示

### boss1（PM）への指示
レポートやログファイルを作成する際は、必ず以下のディレクトリに配置：
- レポート: `.claude/organization/reports/`
- ログ: `.claude/organization/logs/`
- 一時ファイル: `.claude/organization/tmp/`

### workerへの指示
作業結果やレポートは適切なディレクトリに配置し、プロジェクトルートに直接ファイルを作成しない。

## ファイル命名規則

### レポートファイル
- 形式: `[目的]_[対象]_[日付].md`
- 例: `quality_report_2025-07-12.md`

### ログファイル
- 形式: `[送信者]_to_[受信者]_[日付]_[時刻].md`
- 例: `boss1_to_worker1_2025-07-12_1430.md`

### 一時ファイル
- 形式: `tmp_[内容]_[タイムスタンプ].md`
- 例: `tmp_merge_notes_20250712143000.md`

## 実装方法

### 自動配置スクリプト
エージェントがファイルを作成する際に、自動的に適切な場所に配置するヘルパー関数を提供：

```bash
# ファイル配置ヘルパー関数
place_file() {
    local file_type=$1
    local file_name=$2
    local content=$3
    
    case $file_type in
        "report")
            echo "$content" > ".claude/organization/reports/$file_name"
            ;;
        "log")
            echo "$content" > ".claude/organization/logs/$file_name"
            ;;
        "tmp")
            echo "$content" > ".claude/organization/tmp/$file_name"
            ;;
        *)
            echo "Error: Unknown file type"
            return 1
            ;;
    esac
}
```

## まとめ

このガイドラインに従うことで：
- プロジェクトルートがクリーンに保たれる
- ファイルの所在が明確になる
- エージェント間の連携がスムーズになる
- プロジェクトの保守性が向上する

すべてのエージェントとコントリビューターは、このガイドラインに従ってファイルを配置してください。
