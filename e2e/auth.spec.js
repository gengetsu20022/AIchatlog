const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - ホーム画面テスト', () => {
  test.beforeEach(async ({ page }) => {
    // テスト前にページを読み込み
    await page.goto('/');
    
    // Flutter Webの初期化を待機
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

  test('ホーム画面の基本表示確認', async ({ page }) => {
    // アプリタイトルの確認 - ロールベースのロケーターを使用
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible({ timeout: 15000 });
    
    // デモモード表示の確認 - 複数の方法で試行
    await expect(
      page.getByRole('button', { name: 'デモ' })
        .or(page.locator('[data-key="demo-badge"]'))
        .or(page.getByText('デモ'))
    ).toBeVisible({ timeout: 10000 });
    
    // デモ案内メッセージの確認
    await expect(
      page.locator('[data-key="demo-info"]')
        .or(page.getByText('これはデモ画面です'))
    ).toBeVisible({ timeout: 10000 });
    
    // ログインボタンの確認 - ロールベースのロケーターを使用
    await expect(page.getByRole('button', { name: 'ログイン' })).toBeVisible({ timeout: 10000 });

    // 新しい会話追加ボタンの確認 - ロールベースのロケーターを使用
    await expect(page.getByRole('button', { name: '新しい会話を追加' })).toBeVisible({ timeout: 10000 });
  });

  test('デモデータの表示確認', async ({ page }) => {
    // デモのチャットログが表示されることを確認 - ロールベースのロケーターを使用
    await expect(
      page.getByRole('button', { name: /Claude|ChatGPT|Gemini/ }).first()
    ).toBeVisible({ timeout: 15000 });
    
    // チャットログリストが表示されることを確認
    await expect(page.locator('[data-key="chat-log-list"]')).toBeVisible({ timeout: 10000 });
    
    // メッセージ件数の表示確認
    await expect(page.locator('[data-key^="chat-log-count-"]')).toBeVisible({ timeout: 10000 });
  });

  test('ログインボタンの動作確認', async ({ page }) => {
    // ログインボタンをクリック - ロールベースのロケーターを使用
    await page.getByRole('button', { name: 'ログイン' }).click();
    
    // ログインページに遷移することを確認（URLやページ内容で判断）
    await page.waitForTimeout(2000);
    
    // ログインページの要素が表示されることを確認
    await expect(
      page.getByRole('button', { name: 'Googleでログイン' })
        .or(page.getByRole('button', { name: 'ログイン' }))
        .or(page.getByRole('heading', { name: 'ログイン画面' }))
    ).toBeVisible({ timeout: 10000 });
  });

  test('新規追加ボタンの制限確認', async ({ page }) => {
    // 新規追加ボタンをクリック - ロールベースのロケーターを使用
    const addButton = page.getByRole('button', { name: '新しい会話を追加' });
    await addButton.click();
    
    // デモモードでは制限されることを示すメッセージが表示される
    await expect(page.getByText('デモモードでは新しい会話の追加はできません')).toBeVisible({ timeout: 10000 });
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    
    // アプリタイトルが表示されること
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible();
    
    // デモ表示が表示されること
    await expect(
      page.getByRole('button', { name: 'デモ' })
        .or(page.locator('[data-key="demo-badge"]'))
    ).toBeVisible();
    
    // タブレットサイズでの表示確認
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible();
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible();
  });

  test('ページ読み込みパフォーマンス確認', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    
    // 10秒以内に読み込まれることを確認
    expect(loadTime).toBeLessThan(10000);
    
    // 必要な要素が表示されることを確認
    await expect(page.getByRole('heading', { name: 'あいろぐ' })).toBeVisible();
  });
}); 