const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - デモ画面テスト', () => {
  test.beforeEach(async ({ page }) => {
    // テスト用HTMLページを読み込み
    await page.goto('/test.html');
    await page.waitForLoadState('networkidle');
  });

  test('デモ画面の基本表示確認', async ({ page }) => {
    // アプリタイトルの確認
    await expect(page.locator('.logo')).toBeVisible();
    await expect(page.locator('.logo')).toHaveText('あいろぐ');
    
    // デモバッジの確認
    await expect(page.locator('.demo-badge')).toBeVisible();
    await expect(page.locator('.demo-badge')).toHaveText('デモ');
    
    // ログインボタンの確認（aタグに変更）
    await expect(page.locator('a.button:has-text("ログイン")')).toBeVisible();
    
    // デモ案内メッセージの確認
    await expect(page.locator('.demo-notice')).toBeVisible();
    await expect(page.locator('.demo-notice-text')).toContainText('これはデモ画面です');
  });

  test('チャットログリストの表示確認', async ({ page }) => {
    // チャットカードの確認
    const chatCards = page.locator('.chat-card');
    await expect(chatCards).toHaveCount(3);
    
    // AI名の表示確認
    await expect(page.locator('.card-title:has-text("Claude")')).toBeVisible();
    await expect(page.locator('.card-title:has-text("ChatGPT")')).toBeVisible();
    await expect(page.locator('.card-title:has-text("Gemini")')).toBeVisible();
    
    // メッセージ件数の表示確認
    await expect(page.locator('.message-count').first()).toBeVisible();
    await expect(page.locator('.message-count').first()).toContainText('件のメッセージ');
    
    // 会話プレビューの表示確認
    await expect(page.locator('.preview-text').first()).toBeVisible();
    await expect(page.locator('.preview-text').first()).toContainText('Flutterを学び始めた');
  });

  test('ログインボタンの動作確認', async ({ page }) => {
    // ログインボタンをクリック
    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('ログイン画面に移動します');
      await dialog.accept();
    });
    
    await page.click('a.button:has-text("ログイン")');
  });

  test('新規追加ボタンの制限確認', async ({ page }) => {
    // 新規追加ボタンをクリック
    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('デモモードでは新しい会話の追加はできません');
      await dialog.accept();
    });
    
    await page.click('.fab');
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('.logo')).toBeVisible();
    await expect(page.locator('.demo-badge')).toBeVisible();
    
    // タブレットサイズでの表示確認
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.locator('.logo')).toBeVisible();
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('.logo')).toBeVisible();
  });

  test('ページアクセシビリティ確認', async ({ page }) => {
    // ログインボタンが表示されることを確認
    await expect(page.locator('a.button:has-text("ログイン")')).toBeVisible();
    
    // 新規追加ボタンにtitle属性があることを確認
    await expect(page.locator('.fab')).toHaveAttribute('title', '新しい会話を追加');
    
    // スクリーンリーダー用テキストの存在確認
    await expect(page.locator('.sr-only')).toHaveText('新しい会話を追加');
  });

  test('カードインタラクションの確認', async ({ page }) => {
    // カードクリックでアラートが表示されることを確認
    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('会話の詳細を表示します');
      await dialog.accept();
    });
    
    await page.click('.chat-card').first();
  });
}); 