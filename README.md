# あいろぐ (AI Chat Log)

Flutter Webで構築されたAIチャットログ管理アプリケーションです。

## 機能

- AIとの会話ログの管理
- デモモードでの機能体験
- レスポンシブデザイン対応
- Firebase認証・データベース連携

## E2Eテスト

### 修正内容 (2024年7月)

Flutter WebアプリケーションのE2Eテストが失敗していた問題を修正しました：

#### 問題の原因
- Flutter Webの特殊なHTML構造（Canvasベースの描画）により、Playwrightが通常のセレクタで要素を認識できなかった
- `getByText()`や`getByRole()`などの標準的なセレクタがFlutter Web環境で正しく動作しなかった

#### 修正内容
1. **Flutter側の修正**
   - 各WidgetにKeyを追加（例：`key: Key('app-title')`）
   - HTML側で`data-key`属性として出力されるように設定

2. **Playwrightテスト側の修正**
   - セレクタを`[data-key="xxx"]`形式に変更
   - より確実に要素を特定できるように改善

#### 修正されたファイル
- `lib/pages/home_page.dart` - ホーム画面の要素にKey追加
- `lib/pages/log_input_page.dart` - ログ入力画面の要素にKey追加  
- `lib/pages/chat_detail_page.dart` - チャット詳細画面の要素にKey追加
- `e2e/auth.spec.js` - セレクタをKeyベースに変更
- `e2e/chat-log.spec.js` - セレクタをKeyベースに変更
- `e2e/chat-detail.spec.js` - セレクタをKeyベースに変更

#### テスト実行方法
```bash
# 全テスト実行
npx playwright test

# 特定のブラウザでのテスト実行
npx playwright test --project=chromium

# テストレポートの表示
npx playwright show-report
```

## 開発環境のセットアップ

### 前提条件
- Flutter 3.24.5以上
- Node.js 18以上
- npm

### セットアップ手順

1. リポジトリのクローン
```bash
git clone https://github.com/gengetsu20022/AIchatlog.git
cd AIchatlog
```

2. Flutter依存関係のインストール
```bash
flutter pub get
```

3. Node.js依存関係のインストール
```bash
npm install
```

4. Playwrightブラウザのインストール
```bash
npx playwright install
```

5. 環境変数の設定
```bash
cp env.example .env
# .envファイルを編集して必要な値を設定
```

### 開発サーバーの起動

```bash
# Flutter Webアプリケーションの起動
flutter run -d web-server --web-port 8080

# 別のターミナルでE2Eテストの実行
npx playwright test
```

## デプロイ

### Firebase Hosting

```bash
# ビルド
flutter build web --release

# デプロイ
firebase deploy --only hosting
```

## ライセンス

MIT License

## 貢献

プルリクエストやイシューの報告を歓迎します。
