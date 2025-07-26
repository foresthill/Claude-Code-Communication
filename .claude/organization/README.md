# 📚 物語執筆チーム用ディレクトリ構造

## ディレクトリ説明

### 📖 stories/
物語の原稿を管理するメインディレクトリ

- **drafts/** - 初稿・下書き
  - `story_v1_initial.md` - ライターの初稿
  - `story_v2_revised.md` - 推敲版
  
- **revisions/** - 編集作業中の原稿
  - `story_edited.md` - 編集者による改稿
  - `story_notes.md` - 編集メモ
  
- **final/** - 完成原稿
  - `story_final.md` - 最終校正済み原稿
  - `story_published.md` - 出版用最終版

### 📋 plots/
プロットや構成案を保存

- `plot_outline.md` - 基本プロット
- `plot_detailed.md` - 詳細プロット
- `chapter_breakdown.md` - 章立て構成

### 📝 notes/
各エージェントの作業メモ

- `character_profiles.md` - キャラクター設定
- `world_building.md` - 世界観設定
- `theme_notes.md` - テーマに関するメモ
- `revision_history.md` - 改稿履歴

### 📊 reports/
進捗報告や品質レポート

- `progress_report.md` - 進捗状況
- `proofreading_report.md` - 校正報告
- `quality_checklist.md` - 品質チェック

### 📜 logs/
作業ログや通信記録

- `communication_log.txt` - エージェント間通信
- `version_history.log` - バージョン履歴
- `progress.log` - 進捗ログ

### 🗑️ tmp/
一時ファイル

- `draft_backup.md` - 自動バックアップ
- `working_copy.md` - 作業中コピー

## ファイル命名規則

### バージョン管理
```
story_v[番号]_[状態].md
例：story_v1_initial.md
　　story_v2_edited.md
　　story_v3_final.md
```

### 日付付きバックアップ
```
story_backup_[YYYYMMDD]_[HHMM].md
例：story_backup_20240726_1430.md
```

### 章別ファイル（長編の場合）
```
chapter_[番号]_[タイトル].md
例：chapter_01_beginning.md
　　chapter_02_encounter.md
```

## ワークフロー

### 1. 企画段階
```
editor-in-chief → plots/plot_outline.md
editor → plots/plot_detailed.md
```

### 2. 執筆段階
```
writer → stories/drafts/story_v1_initial.md
writer → notes/character_profiles.md
```

### 3. 編集段階
```
copy-editor → stories/revisions/story_edited.md
copy-editor → notes/revision_history.md
```

### 4. 校正段階
```
proofreader → stories/final/story_final.md
proofreader → reports/proofreading_report.md
```

## 使用例

### 新規プロジェクト開始時
```bash
# プロット作成
echo "# [作品名]のプロット" > plots/plot_outline.md

# キャラクター設定
echo "# キャラクター設定" > notes/character_profiles.md

# 進捗記録開始
echo "[$(date)] プロジェクト開始" > logs/progress.log
```

### 原稿のバージョン管理
```bash
# バックアップ作成
cp stories/drafts/story_v1_initial.md \
   stories/drafts/story_backup_$(date +%Y%m%d_%H%M).md

# 新バージョン作成
cp stories/drafts/story_v1_initial.md \
   stories/drafts/story_v2_revised.md
```

### 進捗確認
```bash
# 最新の状態確認
ls -la stories/*/
tail -n 10 logs/progress.log
```

## 注意事項

1. **定期的なバックアップ**: 重要な編集前には必ずバックアップ
2. **明確なバージョン管理**: どの段階の原稿か一目でわかるように
3. **メモの活用**: アイデアや変更理由は notes/ に記録
4. **進捗の可視化**: logs/ で作業履歴を追跡可能に

## セキュリティとプライバシー

- 完成前の原稿は外部に漏らさない
- 個人的なメモは notes/private/ に保存
- 定期的に tmp/ をクリーンアップ