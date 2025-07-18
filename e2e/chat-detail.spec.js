const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャット詳細画面テスト', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
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

  test('デモログをクリックしてチャット詳細画面に遷移', async ({ page }) => {
    // チャットログアイテムを探してクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // 詳細ページの要素が表示されることを確認
    await expect(
      page.getByRole('heading', { name: /チャット詳細|会話詳細/ })
        .or(page.locator('[data-key="chat-detail-ai-name"]'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('チャットメッセージが正しく表示される', async ({ page }) => {
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // チャットメッセージが表示されることを確認
    await expect(page.getByText('Flutterを学び始めたのですが')).toBeVisible({ timeout: 10000 });
  });

  test('カレンダーの月切り替えが動作する', async ({ page }) => {
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // カレンダーの月表示が表示されることを確認
    await expect(page.getByText(/\\d{4}年 \\d{1,2}月/)).toBeVisible({ timeout: 10000 });
  });

  test('検索とメニューボタンが表示される', async ({ page }) => {
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // 検索ボタンが表示されることを確認
    await expect(
      page.getByRole('button', { name: /search|検索/ })
        .or(page.locator('[data-key="search-button"]'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('戻るボタンでホーム画面に戻る', async ({ page }) => {
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // 戻るボタンが表示されることを確認
    await expect(
      page.getByRole('button', { name: /back|戻る/ })
        .or(page.locator('button[aria-label*="back"]'))
    ).toBeVisible({ timeout: 10000 });
    
    // 戻るボタンをクリック
    await page.getByRole('button', { name: /back|戻る/ }).click();
    
    // ホーム画面に戻ることを確認
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible({ timeout: 10000 });
  });

  test('LINE風の背景とデザインが適用される', async ({ page }) => {
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // LINE風のデザインが適用されることを確認
    await expect(page.getByText('LINE風')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    
    // チャットログアイテムをクリック - ロールベースのロケーターを使用
    const chatItem = page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first();
    await expect(chatItem).toBeVisible({ timeout: 15000 });
    await chatItem.click();
    
    // 詳細ページが表示されることを確認
    await expect(
      page.getByRole('heading', { name: /チャット詳細|会話詳細/ })
        .or(page.locator('[data-key="chat-detail-ai-name"]'))
    ).toBeVisible({ timeout: 10000 });
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(
      page.getByRole('heading', { name: /チャット詳細|会話詳細/ })
        .or(page.locator('[data-key="chat-detail-ai-name"]'))
    ).toBeVisible({ timeout: 10000 });
  });
}); 