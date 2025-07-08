# 🔧 Firebase Console 手動セットアップ手順

## 🚨 重要：APIキー再生成とセキュリティ強化

### 📋 現在の状況
- プロジェクトID: `aichatlog-5ade1`
- 現在のAPIキー: `AIzaSyAvM7AHsskCGx43BSaE8OAj_v8sjg59N9o` ⚠️（要再生成）
- 環境変数化: ✅ 完了

## 🔑 ステップ1: 新しいAPIキーの生成

### 1.1 Firebase Console へアクセス
1. [Firebase Console](https://console.firebase.google.com/) を開く
2. プロジェクト `aichatlog-5ade1` を選択

### 1.2 新しいWebアプリの作成（推奨）
1. プロジェクト概要 → 「アプリを追加」
2. ウェブアプリ（`</>`）を選択
3. アプリの名前: `ailog-secure-web`
4. 「Firebase Hosting も設定する」はチェックしない
5. 「アプリを登録」をクリック

### 1.3 新しい設定情報の取得
新しいアプリが作成されると、以下のような設定情報が表示されます：

```javascript
const firebaseConfig = {
  apiKey: "AIza...（新しいAPIキー）",
  authDomain: "aichatlog-5ade1.firebaseapp.com",
  projectId: "aichatlog-5ade1",
  storageBucket: "aichatlog-5ade1.firebasestorage.app",
  messagingSenderId: "715344161518",
  appId: "1:715344161518:web:（新しいアプリID）",
  measurementId: "G-（新しいMeasurement ID）"
};
```

## 🔄 ステップ2: .envファイルの更新

### 2.1 新しい値で.envファイルを更新

```env
# Firebase Web Configuration（新しい値）
FIREBASE_API_KEY=AIza...（新しいAPIキー）
FIREBASE_APP_ID=1:715344161518:web:（新しいアプリID）
FIREBASE_MESSAGING_SENDER_ID=715344161518
FIREBASE_PROJECT_ID=aichatlog-5ade1
FIREBASE_AUTH_DOMAIN=aichatlog-5ade1.firebaseapp.com
FIREBASE_STORAGE_BUCKET=aichatlog-5ade1.firebasestorage.app
FIREBASE_MEASUREMENT_ID=G-（新しいMeasurement ID）

# その他の設定（既存のまま）
FIREBASE_ANDROID_APP_ID=1:715344161518:android:YOUR_ANDROID_APP_ID
FIREBASE_IOS_APP_ID=1:715344161518:ios:YOUR_IOS_APP_ID
FIREBASE_IOS_BUNDLE_ID=com.example.ailog
FIREBASE_MACOS_APP_ID=1:715344161518:macos:YOUR_MACOS_APP_ID
FIREBASE_WINDOWS_APP_ID=1:715344161518:windows:YOUR_WINDOWS_APP_ID
ENVIRONMENT=development
DEBUG_MODE=true
MAX_REQUESTS_PER_MINUTE=60
MAX_REQUESTS_PER_HOUR=1000
```

## 🗑️ ステップ3: 古いAPIキーの無効化

### 3.1 古いWebアプリの削除
1. Firebase Console → プロジェクト設定 → 全般タブ
2. 「マイアプリ」セクションで古いWebアプリを探す
3. 古いアプリの設定（⚙️）→ 「アプリを削除」

### 3.2 APIキーの制限設定（推奨）
1. [Google Cloud Console](https://console.cloud.google.com/) を開く
2. プロジェクト `aichatlog-5ade1` を選択
3. 「APIとサービス」→「認証情報」
4. 新しいAPIキーを選択
5. 「アプリケーションの制限」で以下を設定：
   - HTTPリファラー（ウェブサイト）
   - 許可するリファラー: `https://aichatlog-5ade1.firebaseapp.com/*`

## 🛡️ ステップ4: セキュリティ強化

### 4.1 Firebase Security Rules の設定
1. Firebase Console → Firestore Database → ルール
2. 以下のルールを適用：

```javascript
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

### 4.2 Firebase Authentication の設定
1. Firebase Console → Authentication → Sign-in method
2. 必要な認証方法のみを有効化（例：Google）
3. 承認済みドメインに本番ドメインを追加

### 4.3 使用量アラートの設定
1. Firebase Console → 使用量と請求額
2. 「予算アラート」を設定
3. 月額制限を設定（例：$10）

## ✅ ステップ5: 動作確認

### 5.1 アプリケーションの起動テスト
```bash
# Docker環境での確認
docker-compose up development

# ログで以下が表示されることを確認
# ✅ Firebase初期化成功
# 🔧 Firebase Configuration Status:
#   Project ID: aich****de1
#   API Key: AIza***（新しいキー）
```

### 5.2 機能テスト
1. ユーザー認証の動作確認
2. Firestore読み書きの動作確認
3. エラーログの確認

## 🚨 緊急時の対応

### APIキーが再び漏洩した場合
1. 即座にFirebase Console で該当アプリを削除
2. 新しいWebアプリを作成
3. `.env`ファイルを更新
4. アプリケーションを再起動

### 不正アクセスを検知した場合
1. Firebase Console → Authentication → ユーザー で不正ユーザーを削除
2. Security Rules を一時的に厳格化
3. アクセスログを確認

## 📊 監視とメンテナンス

### 定期的な確認項目
- [ ] Firebase Console での使用量チェック（週次）
- [ ] 認証ユーザーのアクティビティ確認（週次）
- [ ] Security Rules の見直し（月次）
- [ ] APIキーの制限設定確認（月次）

---

**⚠️ 重要**: この手順を完了するまで、リポジトリをパブリックにしないでください。セキュリティは最優先事項です。 