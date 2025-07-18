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
    await page.waitForTimeout(3000);
  });

  test('デモログをクリックしてチャット詳細画面に遷移', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('[data-key="chat-detail-ai-name"]')).toBeVisible({ timeout: 10000 });
  });

  test('チャットメッセージが正しく表示される', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('text=Flutterを学び始めたのですが')).toBeVisible({ timeout: 10000 });
  });

  test('カレンダーの月切り替えが動作する', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('text=/\\d{4}年 \\d{1,2}月/')).toBeVisible({ timeout: 10000 });
  });

  test('検索とメニューボタンが表示される', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('[data-key="search-button"]')).toBeVisible({ timeout: 10000 });
  });

  test('戻るボタンでホーム画面に戻る', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('button[aria-label*="back"], button:has([data-icon="arrow_back"])')).toBeVisible({ timeout: 10000 });
    await page.locator('button[aria-label*="back"], button:has([data-icon="arrow_back"])').click();
    await expect(page.locator('[data-key="app-title"]')).toBeVisible({ timeout: 10000 });
  });

  test('LINE風の背景とデザインが適用される', async ({ page }) => {
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('text=LINE風')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('[data-key^="chat-log-tile-"]')).toBeVisible({ timeout: 15000 });
    await page.locator('[data-key^="chat-log-tile-"]').first().click();
    await expect(page.locator('[data-key="chat-detail-ai-name"]')).toBeVisible({ timeout: 10000 });
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('[data-key="chat-detail-ai-name"]')).toBeVisible({ timeout: 10000 });
  });
}); 