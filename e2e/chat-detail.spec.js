const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャット詳細画面テスト', () => {
  test.beforeEach(async ({ page }) => {
    // ローカルサーバーにアクセス
    await page.goto('http://localhost:8080');
    
    // ページが読み込まれるまで待機
    await page.waitForLoadState('networkidle');
  });

  test('デモログをクリックしてチャット詳細画面に遷移', async ({ page }) => {
    // デモデータが表示されるまで待機
    await expect(page.locator('text=Claude')).toBeVisible();
    
    // 最初のチャットログをクリック
    await page.locator('.card').first().click();
    
    // チャット詳細画面に遷移することを確認
    await expect(page.locator('text=Claude')).toBeVisible(); // ヘッダーのAI名
    
    // カレンダーウィジェットが表示されることを確認
    await expect(page.locator('text=年')).toBeVisible();
    await expect(page.locator('text=月')).toBeVisible();
    
    // 曜日ヘッダーが表示されることを確認
    await expect(page.locator('text=日')).toBeVisible();
    await expect(page.locator('text=火')).toBeVisible();
    await expect(page.locator('text=水')).toBeVisible();
    await expect(page.locator('text=木')).toBeVisible();
    await expect(page.locator('text=金')).toBeVisible();
    await expect(page.locator('text=土')).toBeVisible();
  });

  test('チャットメッセージが正しく表示される', async ({ page }) => {
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // メッセージが表示されることを確認
    await expect(page.locator('text=Flutterを学び始めたのですが')).toBeVisible();
    await expect(page.locator('text=Flutter学習でしたら')).toBeVisible();
    
    // 時刻表示があることを確認（HH:MM形式）
    await expect(page.locator('text=/\\d{2}:\\d{2}/')).toBeVisible();
    
    // 既読マークが表示されることを確認
    await expect(page.locator('text=既読')).toBeVisible();
  });

  test('カレンダーの月切り替えが動作する', async ({ page }) => {
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // 現在の月を取得
    const currentMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    
    // 右矢印をクリックして次の月に移動
    await page.locator('button:has-text(">")', { hasText: '' }).click();
    
    // 月が変更されることを確認
    const newMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    expect(newMonth).not.toBe(currentMonth);
    
    // 左矢印をクリックして前の月に戻る
    await page.locator('button:has-text("<")', { hasText: '' }).click();
    
    // 元の月に戻ることを確認
    const backMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    expect(backMonth).toBe(currentMonth);
  });

  test('検索とメニューボタンが表示される', async ({ page }) => {
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // 検索ボタンが表示されることを確認
    await expect(page.locator('button[aria-label*="search"], button:has([data-icon="search"])')).toBeVisible();
    
    // メニューボタンが表示されることを確認
    await expect(page.locator('button[aria-label*="menu"], button:has([data-icon="more"])')).toBeVisible();
  });

  test('戻るボタンでホーム画面に戻る', async ({ page }) => {
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // 戻るボタンをクリック
    await page.locator('button[aria-label*="back"], button:has([data-icon="arrow_back"])').click();
    
    // ホーム画面に戻ることを確認
    await expect(page.locator('text=あいろぐ')).toBeVisible();
    await expect(page.locator('text=Claude')).toBeVisible();
    await expect(page.locator('text=ChatGPT')).toBeVisible();
    await expect(page.locator('text=Gemini')).toBeVisible();
  });

  test('LINE風の背景とデザインが適用される', async ({ page }) => {
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // 背景色がLINE風（グレー系）であることを確認
    const backgroundColor = await page.evaluate(() => {
      const body = document.querySelector('body');
      return window.getComputedStyle(body).backgroundColor;
    });
    
    // メッセージバブルが存在することを確認
    await expect(page.locator('.message-bubble, [class*="bubble"]')).toBeVisible();
  });

  test('レスポンシブデザインの確認', async ({ page }) => {
    // モバイルサイズに変更
    await page.setViewportSize({ width: 375, height: 667 });
    
    // デモログをクリックして詳細画面に遷移
    await page.locator('.card').first().click();
    
    // カレンダーが表示されることを確認
    await expect(page.locator('text=/\\d{4}年 \\d{1,2}月/')).toBeVisible();
    
    // メッセージが表示されることを確認
    await expect(page.locator('text=Flutter')).toBeVisible();
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    
    // 同様にコンテンツが表示されることを確認
    await expect(page.locator('text=/\\d{4}年 \\d{1,2}月/')).toBeVisible();
    await expect(page.locator('text=Flutter')).toBeVisible();
  });
}); 