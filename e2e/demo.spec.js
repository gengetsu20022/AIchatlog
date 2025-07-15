const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - デモ画面テスト', () => {
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

  test('デモ画面の基本表示確認', async ({ page }) => {
    await expect(page.locator('text=あいろぐ')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=デモ')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=これはデモ画面です')).toBeVisible({ timeout: 10000 });
  });

  test('チャットログリストの表示確認', async ({ page }) => {
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=デモユーザー')).toBeVisible({ timeout: 10000 });
  });

  test('ログインボタンの動作確認', async ({ page }) => {
    await page.click('text=ログイン');
    await page.waitForTimeout(2000);
    await expect(page.locator('text=Googleでログイン').or(page.locator('text=ログイン画面'))).toBeVisible({ timeout: 10000 });
  });

  test('新規追加ボタンの制限確認', async ({ page }) => {
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    await expect(page.locator('text=デモモードでは新しい会話の追加はできません')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('text=あいろぐ')).toBeVisible();
    await expect(page.locator('text=デモ')).toBeVisible();
    
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.locator('text=あいろぐ')).toBeVisible();
    
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('text=あいろぐ')).toBeVisible();
  });

  test('ページアクセシビリティ確認', async ({ page }) => {
    await expect(page.locator('text=ログイン')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")')).toHaveAttribute('title', '新しい会話を追加');
  });

  test('カードインタラクションの確認', async ({ page }) => {
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // カードをクリック
    await page.locator('text=Claude').first().click();
  });
}); 