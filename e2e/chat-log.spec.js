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
             document.body.innerText.includes('あいろぐ') ||
             document.body.innerText.includes('デモ');
    }, { timeout: 30000 });
    
    await page.waitForTimeout(3000);
  });

  test('ログ入力ページの基本機能確認', async ({ page }) => {
    // 新規追加ボタンをクリック
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // ログ入力ページの要素が表示されることを確認
    await expect(page.locator('text=チャットログ入力')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('textarea, input[type="text"]')).toBeVisible({ timeout: 10000 });
  });

  test('チャットログの入力と解析テスト', async ({ page }) => {
    // 新規追加ボタンをクリック
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // サンプルログを入力
    const sampleLog = `ユーザー: Flutterを学び始めたのですが、どこから始めるのがおすすめですか？
AI: Flutter学習でしたら、まず公式ドキュメントの「Get Started」から始めることをおすすめします。基本的なウィジェットの使い方から始めて、徐々に複雑なアプリケーションを作っていくのが良いでしょう。
ユーザー: ありがとうございます！DartとFlutterの関係についても教えてください。
AI: DartはFlutterアプリケーションを書くためのプログラミング言語です。Googleが開発したもので、FlutterフレームワークはDart言語で書かれています。`;

    await page.locator('textarea, input[type="text"]').fill(sampleLog);
    
    // 解析ボタンをクリック
    await page.locator('button:has-text("解析"), button:has-text("分析")').click();
    
    // 解析結果が表示されることを確認
    await expect(page.locator('text=解析完了, text=分析完了')).toBeVisible({ timeout: 10000 });
  });

  test('ログリストページの表示確認', async ({ page }) => {
    // ホーム画面に戻る
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // チャットログが表示されることを確認
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
  });

  test('チャットログ詳細ページの表示確認', async ({ page }) => {
    // チャットログをクリック
    await page.locator('text=Claude').first().click();
    
    // 詳細ページの要素が表示されることを確認
    await expect(page.locator('text=チャット詳細, text=会話詳細')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザイン - チャットログページ', async ({ page }) => {
    // 新規追加ボタンをクリック
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('text=チャットログ入力, text=ログ入力')).toBeVisible({ timeout: 10000 });
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('text=チャットログ入力, text=ログ入力')).toBeVisible({ timeout: 10000 });
  });

  test('ナビゲーション機能確認', async ({ page }) => {
    // 新規追加ボタンをクリック
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // 戻るボタンをクリック
    await page.locator('button[aria-label*="back"], button:has([data-icon="arrow_back"])').click();
    
    // ホーム画面に戻ることを確認
    await expect(page.locator('text=あいろぐ')).toBeVisible({ timeout: 10000 });
  });

  test('エラーハンドリング確認', async ({ page }) => {
    // 新規追加ボタンをクリック
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // 空のログを送信
    await page.locator('button:has-text("解析"), button:has-text("分析")').click();
    
    // エラーメッセージが表示されることを確認
    await expect(page.locator('text=エラー, text=入力してください')).toBeVisible({ timeout: 10000 });
  });
}); 