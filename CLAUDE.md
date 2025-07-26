# Story Writing Team - 物語執筆チーム

## チーム構成
- **EDITOR-IN-CHIEF** (president): 編集長 - 企画・最終承認
- **EDITOR** (boss1): 編集者 - プロット作成・進行管理
- **WRITER** (worker1): 天才ライター - 初稿執筆
- **COPY-EDITOR** (worker2): 敏腕編集者 - 文章編集・推敲
- **PROOFREADER** (worker3): 校正者 - 最終校正

## あなたの役割
- **編集長**: @instructions/editor-in-chief.md
- **編集者**: @instructions/editor.md
- **ライター**: @instructions/writer.md
- **敏腕編集者**: @instructions/copy-editor.md
- **校正者**: @instructions/proofreader.md

## 基本的な作業フロー
```
編集長
  ↓ (企画・テーマ設定)
編集者
  ↓ (プロット・構成作成)
ライター
  ↓ (初稿執筆)
敏腕編集者
  ↓ (構成編集・文章推敲)
校正者
  ↓ (最終校正・品質確認)
編集者
  ↓ (最終確認・統合)
編集長 (承認・完成)
```

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"

# 例：編集者に指示
./agent-send.sh editor "新しい短編小説の企画です。テーマは「再会」でお願いします。"
```

## 原稿管理
```
.claude/organization/
├── stories/        # 原稿保存
│   ├── drafts/     # 下書き
│   ├── revisions/  # 改稿
│   └── final/      # 完成稿
├── plots/          # プロット
├── notes/          # メモ・設定
└── reports/        # 進捗報告
```

## 物語執筆の特徴
- **順次的作業**: 並行開発ではなくバトンタッチ方式
- **同一ファイル編集**: マージではなく改稿の積み重ね
- **創造性重視**: 技術的正確性より芸術的完成度
- **読者体験**: 最終的に読者の心に届くかが基準