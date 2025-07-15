const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - ホーム画面テスト', () => {
  test.beforeEach(async ({ page }) => {
    // テスト前にページを読み込み
    await page.goto('/');
    
    // Flutter Webの初期化を待機
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      // Flutter Webの初期化完了を示すDOM要素やグローバル変数をチェック
      return window.flutterCanvasKit || 
             document.querySelector('flutter-view') ||
             document.querySelector('flt-glass-pane') ||
             document.querySelector('[data-testid]') ||
             document.body.innerText.includes('あいろぐ') ||
             document.body.innerText.includes('デモ');
    }, { timeout: 30000 });
    
    // 追加の初期化時間を確保
    await page.waitForTimeout(3000);
  });

  test('ホーム画面の基本表示確認', async ({ page }) => {
    // アプリタイトルの確認 - Flutter Webではテキストが直接表示される
    await expect(page.locator('text=あいろぐ')).toBeVisible({ timeout: 15000 });
    
    // デモモード表示の確認
    await expect(page.locator('text=デモ')).toBeVisible({ timeout: 10000 });
    
    // デモ案内メッセージの確認
    await expect(page.locator('text=これはデモ画面です')).toBeVisible({ timeout: 10000 });
    
    // ログインボタンの確認 - Flutter Webではボタンが直接表示される
    await expect(page.locator('text=ログイン')).toBeVisible({ timeout: 10000 });

    // 新しい会話追加ボタンの確認 - FloatingActionButton
    await expect(page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")')).toBeVisible({ timeout: 10000 });
  });

  test('デモデータの表示確認', async ({ page }) => {
    // デモのチャットログが表示されることを確認
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // ユーザー名の表示確認
    await expect(page.locator('text=デモユーザー')).toBeVisible({ timeout: 10000 });
    
    // メッセージ件数の表示確認
    await expect(page.locator('text=件')).toBeVisible({ timeout: 10000 });
  });

  test('ログインボタンの動作確認', async ({ page }) => {
    // ログインボタンをクリック
    await page.click('text=ログイン');
    
    // ログインページに遷移することを確認（URLやページ内容で判断）
    await page.waitForTimeout(2000);
    
    // ログインページの要素が表示されることを確認
    await expect(
      page.locator('text=Googleでログイン')
        .or(page.locator('button:has-text("ログイン")'))
        .or(page.locator('text=ログイン画面'))
    ).toBeVisible({ timeout: 10000 });
  });

  test('新規追加ボタンの制限確認', async ({ page }) => {
    // 新規追加ボタンをクリック - FloatingActionButton
    const addButton = page.locator('button[aria-label="新しい会話を追加"], button:has([data-icon="add"]), button:has-text("+")');
    await addButton.click();
    
    // デモモードでは制限されることを示すメッセージが表示される
    await expect(page.locator('text=デモモードでは新しい会話の追加はできません')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    
    // アプリタイトルが表示されること
    await expect(page.locator('text=あいろぐ')).toBeVisible();
    
    // デモ表示が表示されること
    await expect(page.locator('text=デモ')).toBeVisible();
    
    // タブレットサイズでの表示確認
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.locator('text=あいろぐ')).toBeVisible();
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('text=あいろぐ')).toBeVisible();
  });

  test('ページ読み込みパフォーマンス確認', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    
    // 10秒以内に読み込まれることを確認
    expect(loadTime).toBeLessThan(10000);
    
    // 必要な要素が表示されることを確認
    await expect(page.locator('text=あいろぐ')).toBeVisible();
  });
}); 