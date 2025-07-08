# 🛡️ GitHub セキュリティ設定ガイド

## 📋 概要

パブリックリポジトリにする前に、GitHubのセキュリティ機能を適切に設定して、機密情報の漏洩を防ぎます。

## 🔧 必須セキュリティ設定

### 1. **Secret Scanning（シークレットスキャン）**

#### 1.1 設定手順
1. GitHubリポジトリページを開く
2. **Settings** タブをクリック
3. 左サイドバーの **Security & analysis** をクリック
4. **Secret scanning** セクションで **Enable** をクリック

#### 1.2 検出される機密情報
- APIキー（Firebase、AWS、Google Cloud等）
- アクセストークン
- 秘密鍵
- データベース接続文字列
- その他の認証情報

### 2. **Dependency Scanning（依存関係スキャン）**

#### 2.1 Dependabot alerts の有効化
1. **Settings** → **Security & analysis**
2. **Dependabot alerts** で **Enable** をクリック
3. **Dependabot security updates** で **Enable** をクリック

#### 2.2 設定効果
- 脆弱性のある依存関係を自動検出
- セキュリティアップデートの自動提案
- CVE（共通脆弱性識別子）の監視

### 3. **Code Scanning（コードスキャン）**

#### 3.1 GitHub Advanced Security の設定
1. **Settings** → **Security & analysis**
2. **Code scanning** で **Set up** をクリック
3. **CodeQL Analysis** を選択

#### 3.2 Flutter/Dart用の設定
```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    
    strategy:
      fail-fast: false
      matrix:
        language: [ 'dart' ]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.5'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
```

### 4. **Branch Protection Rules（ブランチ保護ルール）**

#### 4.1 設定手順
1. **Settings** → **Branches**
2. **Add rule** をクリック
3. Branch name pattern: `main`
4. 以下のオプションを有効化：

#### 4.2 推奨設定
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1
  - ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
- ✅ **Require conversation resolution before merging**
- ✅ **Include administrators**

### 5. **Repository Secrets の管理**

#### 5.1 環境変数の設定
1. **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 以下のシークレットを追加：

```
FIREBASE_API_KEY_PROD=（本番用APIキー）
FIREBASE_PROJECT_ID=aichatlog-5ade1
DOCKER_USERNAME=（Docker Hub ユーザー名）
DOCKER_PASSWORD=（Docker Hub パスワード）
```

#### 5.2 Environment Secrets（環境別）
- **Development**: 開発用の設定
- **Staging**: ステージング用の設定
- **Production**: 本番用の設定

### 6. **Security Policy の作成**

#### 6.1 SECURITY.md ファイルの作成
```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

セキュリティ脆弱性を発見した場合は、以下の手順で報告してください：

1. **公開の Issue は作成しないでください**
2. メール: [your-email@example.com] に連絡
3. 24時間以内に確認の返信をいたします
4. 修正まで情報を非公開にしてください

## Security Measures

- 定期的な依存関係の更新
- Secret scanning の有効化
- Code scanning による静的解析
- 環境変数による機密情報の管理
```

### 7. **GitHub Actions セキュリティ**

#### 7.1 Workflow の権限制限
```yaml
# .github/workflows/security-check.yml
name: Security Check

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  security-events: write

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run security scan
        run: |
          # 機密情報の検索
          if grep -r "AIza" . --exclude-dir=.git; then
            echo "⚠️ Potential API key found!"
            exit 1
          fi
          
          # .env ファイルの検出
          if find . -name ".env" -not -path "./.git/*"; then
            echo "⚠️ .env file found in repository!"
            exit 1
          fi
```

### 8. **Two-Factor Authentication（2FA）**

#### 8.1 GitHub アカウントの2FA有効化
1. GitHub右上のプロフィール → **Settings**
2. **Password and authentication**
3. **Enable two-factor authentication**
4. **Authenticator app** または **SMS** を選択

### 9. **Access Control（アクセス制御）**

#### 9.1 Collaborators の管理
1. **Settings** → **Manage access**
2. 必要最小限の権限を付与
3. 定期的なアクセス権の見直し

#### 9.2 Deploy Keys の設定
```bash
# SSH キーの生成（デプロイ用）
ssh-keygen -t ed25519 -C "deploy@aichatlog"

# 公開鍵をGitHubに追加
# Settings → Deploy keys → Add deploy key
```

## 🚨 緊急時の対応手順

### セキュリティインシデント発生時

1. **即座にリポジトリを Private に変更**
2. **問題のあるコミットを特定**
3. **機密情報を無効化**（APIキー再生成等）
4. **Git history の清掃**（必要に応じて）
5. **インシデントレポートの作成**

### Git History の清掃
```bash
# 特定ファイルを履歴から完全削除
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env' \
  --prune-empty --tag-name-filter cat -- --all

# 強制プッシュ（注意：破壊的操作）
git push origin --force --all
```

## 📊 定期的なセキュリティチェック

### 週次チェック項目
- [ ] Dependabot alerts の確認
- [ ] Secret scanning results の確認
- [ ] 不審なアクセスログの確認

### 月次チェック項目
- [ ] 依存関係の更新
- [ ] アクセス権限の見直し
- [ ] セキュリティポリシーの更新
- [ ] Backup の確認

### 四半期チェック項目
- [ ] 全体的なセキュリティ監査
- [ ] ペネトレーションテスト
- [ ] インシデント対応手順の見直し

---

**⚠️ 重要**: これらの設定を完了してからリポジトリをパブリックにしてください。セキュリティは継続的なプロセスです。 