# 🛡️ GitHub セキュリティ設定チェックリスト

## 📋 パブリックリポジトリ公開前の必須チェック項目

### ✅ **1. Repository Settings**

#### Basic Security
- [ ] **Secret Scanning** を有効化
  - Settings → Security & analysis → Secret scanning → Enable
- [・ ] **Dependabot alerts** を有効化
  - Settings → Security & analysis → Dependabot alerts → Enable
- [・ ] **Dependabot security updates** を有効化
  - Settings → Security & analysis → Dependabot security updates → Enable

#### Advanced Security（GitHub Pro以上）
- [ ] **Code scanning** を設定
  - Settings → Security & analysis → Code scanning → Set up
  - CodeQL Analysis を選択
- [ ] **Private vulnerability reporting** を有効化
  - Settings → Security & analysis → Private vulnerability reporting → Enable

### ✅ **2. Branch Protection Rules**

- [ ] **main ブランチの保護ルール**を設定
  - Settings → Branches → Add rule
  - Branch name pattern: `main`
  
#### 推奨設定項目
- [ ・] **Require a pull request before merging**
  - [ ・] Require approvals: 1人以上
  - [ ]・ Dismiss stale PR approvals when new commits are pushed
- [ ]・ **Require status checks to pass before merging**
  - [ ] Require branches to be up to date before merging
  - [ ] Status checks: Security Check, Tests
- [ ] **Require conversation resolution before merging**
- [ ] **Include administrators**

### ✅ **3. GitHub Actions Security**

- [ ] **Workflow permissions** を制限
  - Settings → Actions → General → Workflow permissions
  - "Read repository contents and package permissions" を選択
- [ ] **セキュリティワークフロー**を作成
  - [ ] `.github/workflows/security-check.yml` ✅（作成済み）
- [ ] **Secrets管理**を設定
  - Settings → Secrets and variables → Actions

### ✅ **4. Access Control**

- [ ] **Repository visibility** を確認
  - Settings → General → Repository visibility
- [ ] **Collaborators** の権限を最小限に制限
  - Settings → Manage access
- [ ] **Deploy keys** を適切に設定（必要に応じて）
  - Settings → Deploy keys

### ✅ **5. Security Documentation**

- [ ] **SECURITY.md** ファイルを作成 ✅（作成済み）
- [ ] **セキュリティポリシー**を明確に記載
- [ ] **脆弱性報告手順**を明記

### ✅ **6. File Security Check**

#### 機密情報の除外確認
- [ ] **.env ファイル**がリポジトリに含まれていない
- [ ] **APIキー**がコードに含まれていない
- [ ] **パスワード**がハードコーディングされていない
- [ ] **秘密鍵**がリポジトリに含まれていない

#### .gitignore の確認
- [ ] `.env` が .gitignore に含まれている ✅
- [ ] `firebase_options_backup.dart` が .gitignore に含まれている ✅
- [ ] その他の機密ファイルが適切に除外されている

### ✅ **7. GitHub Account Security**

- [ ] **Two-Factor Authentication (2FA)** を有効化
  - Profile → Settings → Password and authentication
- [ ] **SSH keys** を適切に管理
  - Profile → Settings → SSH and GPG keys
- [ ] **Personal access tokens** を定期的に見直し
  - Profile → Settings → Developer settings → Personal access tokens

### ✅ **8. Monitoring & Alerts**

- [ ] **Security alerts** の通知設定
  - Profile → Settings → Notifications → Security alerts
- [ ] **Email notifications** を適切に設定
- [ ] **GitHub Mobile** アプリでの通知設定（推奨）

## 🔧 **設定手順の詳細**

### Secret Scanning の設定
```
1. リポジトリページ → Settings
2. 左サイドバー → Security & analysis
3. Secret scanning → Enable
4. Push protection → Enable（推奨）
```

### Branch Protection Rules の設定
```
1. Settings → Branches
2. Add rule をクリック
3. Branch name pattern: main
4. 必要なオプションをチェック
5. Create をクリック
```

### GitHub Actions Secrets の設定
```
1. Settings → Secrets and variables → Actions
2. New repository secret をクリック
3. 必要なシークレットを追加:
   - FIREBASE_API_KEY_PROD
   - FIREBASE_PROJECT_ID
   - その他の本番用設定
```

## 🚨 **緊急時の対応**

### セキュリティインシデント発生時
1. **即座にリポジトリをPrivateに変更**
2. **問題のあるコミットを特定**
3. **機密情報を無効化**（APIキー再生成等）
4. **Security Advisory を作成**
5. **修正後にPublicに戻す**

### 連絡先
- **GitHub Security**: security@github.com
- **プロジェクト管理者**: [your-email@example.com]

## 📊 **定期的なチェック**

### 週次チェック
- [ ] Security alerts の確認
- [ ] Dependabot alerts の確認
- [ ] 不審なアクティビティの確認

### 月次チェック
- [ ] Access permissions の見直し
- [ ] Security policies の更新
- [ ] Dependencies の更新

### 四半期チェック
- [ ] 全体的なセキュリティ監査
- [ ] ペネトレーションテスト
- [ ] インシデント対応手順の見直し

---

**⚠️ 重要**: このチェックリストの全項目を完了してからリポジトリをパブリックにしてください。

**📅 最終更新**: 2025年7月8日  
**📋 チェック実行者**: _______________  
**📅 チェック実行日**: _______________ 