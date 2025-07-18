const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャットログ機能テスト', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      return window.flutterCanvasKit || 
             document.querySelector('flutter-view') ||
             document.querySelector('flt-glass-pane') ||
             document.querySelector('[data-key]') ||
             document.body.innerText.includes('あいろぐ') ||
             document.body.innerText.includes('デモ');
    }, { timeout: 30000 });
    
    // アプリのメインタイトルが表示されるまで待機（ロード完了の指標）
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible({ timeout: 45000 });
  });

  test('ログ入力ページの基本機能確認', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await expect(addButton).toBeVisible();
    await addButton.click();
    
    // ログ入力ページの要素が表示されることを確認
    await expect(
      page.getByRole('heading', { name: '会話ログを追加' })
        .or(page.locator('[data-key="log-input-title"]'))
    ).toBeVisible({ timeout: 10000 });
    
    await expect(
      page.locator('[data-key="chat_log_field"]')
        .or(page.getByRole('textbox', { name: /会話ログ/ }))
    ).toBeVisible({ timeout: 10000 });
  });

  test('チャットログの入力と解析テスト', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await expect(addButton).toBeVisible();
    await addButton.click();
    
    // サンプルログを入力
    const sampleLog = `ユーザー: Flutterを学び始めたのですが、どこから始めるのがおすすめですか？
AI: Flutter学習でしたら、まず公式ドキュメントの「Get Started」から始めることをおすすめします。基本的なウィジェットの使い方から始めて、徐々に複雑なアプリケーションを作っていくのが良いでしょう。
ユーザー: ありがとうございます！DartとFlutterの関係についても教えてください。
AI: DartはFlutterアプリケーションを書くためのプログラミング言語です。Googleが開発したもので、FlutterフレームワークはDart言語で書かれています。`;

    await page.locator('[data-key="chat_log_field"]').fill(sampleLog);
    
    // 解析ボタンをクリック - ロールベースのロケーターを使用
    await page.getByRole('button', { name: '保存' }).click();
    
    // 解析結果が表示されることを確認
    await expect(
      page.getByText('解析完了')
        .or(page.getByText('分析完了'))
        .or(page.getByText('会話ログが保存されました'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('ログリストページの表示確認', async ({ page }) => {
    // ホーム画面に戻る
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // チャットログが表示されることを確認 - ロールベースのロケーターを使用
    await expect(
      page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first()
        .or(page.locator('[data-key="chat-log-list"]'))
    ).toBeVisible({ timeout: 15000 });
  });

  test('チャットログ詳細ページの表示確認', async ({ page }) => {
    // チャットログをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible();
    await chatItem.click();
    
    // 詳細ページの要素が表示されることを確認
    await expect(
      page.getByRole('heading', { name: /チャット詳細|会話詳細/ })
        .or(page.locator('[data-key="chat-detail-ai-name"]'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザイン - チャットログページ', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await expect(addButton).toBeVisible();
    await addButton.click();
    
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(
      page.getByRole('heading', { name: '会話ログを追加' })
        .or(page.locator('[data-key="log-input-title"]'))
    ).toBeVisible({ timeout: 10000 });
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(
      page.getByRole('heading', { name: '会話ログを追加' })
        .or(page.locator('[data-key="log-input-title"]'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('ナビゲーション機能確認', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await expect(addButton).toBeVisible();
    await addButton.click();
    
    // 戻るボタンをクリック
    await page.getByRole('button', { name: /back|戻る/ }).click();
    
    // ホーム画面に戻ることを確認
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible({ timeout: 10000 });
  });

  test('エラーハンドリング確認', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await expect(addButton).toBeVisible();
    await addButton.click();
    
    // 空のログを送信
    await page.getByRole('button', { name: '保存' }).click();
    
    // エラーメッセージが表示されることを確認
    await expect(
      page.getByText('エラー')
        .or(page.getByText('入力してください'))
        .or(page.getByText('を入力してください'))
    ).toBeVisible({ timeout: 10000 });
  });
}); 