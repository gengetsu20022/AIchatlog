# 🐳 あいろぐ Docker E2Eテスト環境

昨日の課題（ポート競合・サーバー起動問題）を解決するため、完全に分離されたDocker環境でE2Eテストを実行します。

## 📋 事前準備

### 1. Docker Desktop のインストール・起動

**Windows:**
1. [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows/) をダウンロード・インストール
2. Docker Desktop を起動
3. タスクバーの Docker アイコンが緑色になることを確認

**確認方法:**
```powershell
docker --version
docker ps
```

### 2. 必要ファイルの確認

以下のファイルが存在することを確認：
- `docker-compose.e2e.yml` - Docker Compose設定
- `Dockerfile.playwright` - Playwrightテスト環境
- `docker-entrypoint-playwright.sh` - テスト実行エントリーポイント
- `playwright.config.js` - Playwright設定
- `package.json` - Node.js依存関係
- `e2e/` ディレクトリ - テストファイル

## 🚀 使用方法

### Windows (PowerShell)

```powershell
# ヘルプ表示
.\run_e2e_docker.ps1 -Help

# Docker環境をビルド
.\run_e2e_docker.ps1 -Build

# E2Eテスト実行
.\run_e2e_docker.ps1 -Test

# 特定ブラウザのみテスト
.\run_e2e_docker.ps1 -Test -Browser chromium

# ビルド→テスト を一度に実行
.\run_e2e_docker.ps1 -Build -Test

# テストレポート表示
.\run_e2e_docker.ps1 -Report

# Docker環境クリーンアップ
.\run_e2e_docker.ps1 -Clean
```

### Linux/Mac (Bash)

```bash
# 実行権限付与（初回のみ）
chmod +x run_e2e_docker.sh

# ヘルプ表示
./run_e2e_docker.sh -h

# Docker環境をビルド
./run_e2e_docker.sh -b

# E2Eテスト実行
./run_e2e_docker.sh -t

# 特定ブラウザのみテスト
./run_e2e_docker.sh -t --browser firefox

# ビルド→テスト を一度に実行
./run_e2e_docker.sh -b -t

# テストレポート表示
./run_e2e_docker.sh -r

# Docker環境クリーンアップ
./run_e2e_docker.sh -c
```

## 🔧 Docker環境の構成

### サービス構成

1. **flutter-web** - Flutter Web開発サーバー
   - ポート: 8080
   - Flutter Webアプリのビルド・配信
   - ヘルスチェック機能付き

2. **playwright-tests** - Playwrightテスト実行環境
   - Flutter Webサーバーの起動を待機
   - 複数ブラウザでのテスト実行
   - HTMLレポート・スクリーンショット・動画生成

### ネットワーク分離

- 専用ネットワーク `e2e-network` で完全分離
- ホストのポート競合を回避
- サービス間の安全な通信

### ボリューム管理

- `flutter_pub_cache` - Flutter依存関係キャッシュ
- `playwright_cache` - Playwrightブラウザキャッシュ
- プロジェクトディレクトリのマウント

## 🎯 昨日の課題解決

### ✅ 解決された問題

1. **ポート競合 (9323, 8080)**
   - Docker内部ネットワークで完全分離
   - ホストポートとの競合なし

2. **Flutter コマンド PATH問題**
   - Docker イメージに Flutter 環境をプリインストール
   - 環境変数の問題を回避

3. **HTTP Server 起動失敗**
   - Docker Compose でサービス依存関係を管理
   - ヘルスチェックによる確実な起動順序

4. **プロセス競合**
   - 各テスト実行で新しいコンテナを使用
   - 完全にクリーンな環境でテスト実行

### 🔄 テスト実行フロー

1. **環境準備**
   - Docker イメージビルド
   - 依存関係インストール

2. **Flutter Web起動**
   - アプリケーションビルド
   - HTTP サーバー起動
   - ヘルスチェック完了待機

3. **テスト実行**
   - Playwright テスト開始
   - 複数ブラウザ並列実行
   - レポート・アーティファクト生成

4. **後片付け**
   - コンテナ自動停止・削除
   - リソース解放

## 📊 テスト結果

### 生成されるファイル

- `playwright-report/` - HTMLテストレポート
- `test-results/` - スクリーンショット・動画
- `test-results.json` - JSON形式の結果

### 対応ブラウザ

- **デスクトップ**: Chromium, Firefox, WebKit
- **モバイル**: Mobile Chrome (Pixel 5), Mobile Safari (iPhone 12)

## 🛠️ トラブルシューティング

### Docker Desktop が起動しない

```powershell
# Docker Desktop の状態確認
docker --version
docker ps

# エラーが出る場合は Docker Desktop を再起動
```

### ビルドエラー

```powershell
# キャッシュクリアしてリビルド
.\run_e2e_docker.ps1 -Clean
.\run_e2e_docker.ps1 -Build
```

### テスト失敗

```powershell
# ログ確認
.\run_e2e_docker.ps1 -Logs

# レポート確認
.\run_e2e_docker.ps1 -Report
```

### メモリ不足

```powershell
# 未使用Dockerリソース削除
docker system prune -f
docker volume prune -f
```

## 🔐 セキュリティ

- コンテナは最小権限で実行
- ネットワーク分離によるセキュリティ確保
- 一時的なコンテナ使用（テスト後自動削除）

## 📈 パフォーマンス

- **初回ビルド**: 5-10分（依存関係ダウンロード）
- **2回目以降**: 1-2分（キャッシュ利用）
- **テスト実行**: 2-5分（ブラウザ数による）

## 🎉 メリット

1. **環境の一貫性** - 開発者間で同じ環境
2. **分離性** - ホスト環境への影響なし
3. **再現性** - 常に同じ条件でテスト
4. **スケーラビリティ** - CI/CDへの組み込み容易
5. **保守性** - 設定ファイルによる管理

---

**注意**: 初回実行時はDockerイメージのダウンロードに時間がかかります。十分な時間とディスク容量を確保してください。 