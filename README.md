# あいろぐ (Ailog)

AIとの会話を美しく記録する日記アプリです。

## 機能

- Google認証によるログイン
- AIとの会話ログの記録・管理
- 美しいLINE風チャットUI
- 複数AIサービス対応（ChatGPT、Gemini等）

## 技術スタック

- Flutter Web
- Firebase (Authentication, Firestore)
- Docker
- GitHub Actions + Playwright (E2E Testing)
- Coderabbit (AI Code Review)

## E2Eテスト

このプロジェクトでは、Playwright + GitHub Actionsを使用したE2Eテストを実装しています。

### テスト実行方法

#### Windows (PowerShell)
```powershell
# 初回セットアップ
.\run_e2e_tests.ps1 -Install

# Flutter Webビルド
.\run_e2e_tests.ps1 -Build

# E2Eテスト実行
.\run_e2e_tests.ps1 -Test

# 特定ブラウザでのテスト
.\run_e2e_tests.ps1 -Test -Browser chromium

# モバイルテスト
.\run_e2e_tests.ps1 -Test -Mobile

# テストレポート表示
.\run_e2e_tests.ps1 -Report

# 全工程を一度に実行
.\run_e2e_tests.ps1 -Install -Build -Test
```

#### Linux/Mac (Bash)
```bash
# 初回セットアップ
./run_e2e_tests.sh -i

# Flutter Webビルド
./run_e2e_tests.sh -b

# E2Eテスト実行
./run_e2e_tests.sh -t

# 特定ブラウザでのテスト
./run_e2e_tests.sh -t --browser firefox

# モバイルテスト
./run_e2e_tests.sh -t --mobile

# テストレポート表示
./run_e2e_tests.sh -r

# 全工程を一度に実行
./run_e2e_tests.sh -i -b -t
```

#### Docker環境
```bash
# Docker環境でテスト実行
docker-compose -f docker-compose.playwright.yml up --build

# またはスクリプト経由
./run_e2e_tests.sh -d  # Linux/Mac
.\run_e2e_tests.ps1 -Docker  # Windows
```

### テスト対象ブラウザ

- Chromium (Google Chrome)
- Firefox
- WebKit (Safari)
- Mobile Chrome
- Mobile Safari

### GitHub Actions

プッシュ時、プルリクエスト時に自動でE2Eテストが実行されます。

- **ワークフロー**: `.github/workflows/playwright.yml`
- **並列実行**: 複数ブラウザでのテストを並列実行
- **アーティファクト**: テストレポート、スクリーンショット、動画が保存される

### テストファイル構成

```
e2e/
├── auth.spec.js          # 認証機能のテスト
└── chat-log.spec.js      # チャットログ機能のテスト
```

### CI/CD統合

GitHub Actionsで以下が自動実行されます：

1. Flutter Webアプリのビルド
2. 複数ブラウザでのE2Eテスト実行
3. テストレポートの生成
4. 失敗時のスクリーンショット・動画保存
