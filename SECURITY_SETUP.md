# 🔐 Firebase セキュリティ設定ガイド

## 📋 概要

このプロジェクトでは、セキュリティを強化するためFirebaseの設定情報を環境変数で管理しています。

## 🚨 重要な注意事項

⚠️ **APIキーやプロジェクト情報を直接コードに書かないでください**
⚠️ **`.env`ファイルをGitにコミットしないでください**
⚠️ **本番環境では必ず新しいAPIキーを生成してください**

## 📝 初期設定手順

### 1. 環境変数ファイルの作成

```bash
# テンプレートファイルをコピー
cp env.example .env
```

### 2. Firebase Console での新しいAPIキー生成

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクトを選択
3. 設定 → プロジェクトの設定 → 全般 タブ
4. 「ウェブ API キー」を再生成
5. 古いAPIキーを無効化

### 3. .envファイルの設定

`.env`ファイルを編集して、実際の値を設定してください：

```env
# Firebase Web Configuration
FIREBASE_API_KEY=AIza...（新しく生成したAPIキー）
FIREBASE_APP_ID=1:123456789:web:abcdef123456
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# Firebase Android Configuration
FIREBASE_ANDROID_APP_ID=1:123456789:android:abcdef123456

# Firebase iOS Configuration
FIREBASE_IOS_APP_ID=1:123456789:ios:abcdef123456
FIREBASE_IOS_BUNDLE_ID=com.example.ailog

# Firebase macOS Configuration
FIREBASE_MACOS_APP_ID=1:123456789:macos:abcdef123456

# Firebase Windows Configuration
FIREBASE_WINDOWS_APP_ID=1:123456789:windows:abcdef123456
```

### 4. 依存関係のインストール

```bash
flutter pub get
```

### 5. アプリケーションの起動

```bash
# 開発環境
flutter run -d web

# または Docker
docker-compose up development
```

## 🔧 Docker環境での設定

Docker環境では、`.env`ファイルが自動的に読み込まれます：

```bash
# 開発環境
docker-compose up development

# 本番環境
docker-compose up production
```

## 🛡️ セキュリティベストプラクティス

### 1. Firebase Security Rules の設定

```javascript
// Firestore Security Rules の例
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 認証済みユーザーのみアクセス可能
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 2. API使用量の監視

- Firebase Console で使用量を定期的に確認
- 異常な使用量があった場合は即座にAPIキーを再生成

### 3. 環境別の設定

```env
# 開発環境
ENVIRONMENT=development
DEBUG_MODE=true

# 本番環境
ENVIRONMENT=production
DEBUG_MODE=false
```

## 🚨 緊急時の対応

### APIキーが漏洩した場合

1. **即座にFirebase ConsoleでAPIキーを無効化**
2. **新しいAPIキーを生成**
3. **`.env`ファイルを更新**
4. **アプリケーションを再起動**

### 不正アクセスを検知した場合

1. **Firebase Console でアクティビティログを確認**
2. **Security Rules を強化**
3. **必要に応じて一時的にサービスを停止**

## 📊 設定状況の確認

アプリケーション起動時に、デバッグモードで設定状況が表示されます：

```
🔧 Firebase Configuration Status:
  Project ID: your****-id
  API Key: AIza***N9o
  Auth Domain: your-project-id.firebaseapp.com
  Storage Bucket: your-project-id.firebasestorage.app
  Environment: development
```

## 📞 サポート

設定に問題がある場合は、以下を確認してください：

1. `.env`ファイルが正しく作成されているか
2. 全ての必須環境変数が設定されているか
3. Firebase Console でプロジェクトが有効になっているか
4. APIキーが正しく生成されているか

---

**⚠️ 重要**: このファイルは機密情報を含まないため、リポジトリに含めることができます。実際の設定値は`.env`ファイルに記載し、絶対にGitにコミットしないでください。 