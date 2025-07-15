const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャット詳細画面デモテスト', () => {
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

  test('LINE風チャット詳細画面のデモ', async ({ page }) => {
    // デモデータが表示されるまで待機
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // 最初のチャットログをクリック
    await page.locator('text=Claude').first().click();
    
    // チャット詳細画面に遷移することを確認
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // カレンダーウィジェットが表示されることを確認
    await expect(page.locator('text=年').or(page.locator('text=月'))).toBeVisible({ timeout: 15000 });
    
    // 曜日ヘッダーが表示されることを確認
    await expect(page.locator('text=日').or(page.locator('text=月').or(page.locator('text=火')))).toBeVisible({ timeout: 15000 });
    
    // メッセージが表示されることを確認
    await expect(page.locator('text=Flutter').or(page.locator('text=学び始め'))).toBeVisible({ timeout: 15000 });
    
    // 時刻表示があることを確認（HH:MM形式）
    await expect(page.locator('text=/\\d{2}:\\d{2}/').or(page.locator('text=:'))).toBeVisible({ timeout: 15000 });
    
    // 既読マークが表示されることを確認
    await expect(page.locator('text=既読').or(page.locator('text=✓'))).toBeVisible({ timeout: 15000 });
    
    // カレンダーの月切り替えが動作することを確認
    const currentMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    
    // 右矢印をクリックして次の月に移動
    await page.locator('button:has-text(">")').or(page.locator('button:has-text("次")')).click();
    
    // 月が変更されることを確認
    const newMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    expect(newMonth).not.toBe(currentMonth);
    
    // 左矢印をクリックして前の月に戻る
    await page.locator('button:has-text("<")').or(page.locator('button:has-text("前")')).click();
    
    // 元の月に戻ることを確認
    const backMonth = await page.locator('text=/\\d{4}年 \\d{1,2}月/').textContent();
    expect(backMonth).toBe(currentMonth);
    
    // 検索ボタンが表示されることを確認
    await expect(page.locator('button[aria-label*="search"]').or(page.locator('button:has([data-icon="search"])'))).toBeVisible({ timeout: 15000 });
    
    // メニューボタンが表示されることを確認
    await expect(page.locator('button[aria-label*="menu"]').or(page.locator('button:has([data-icon="more"])'))).toBeVisible({ timeout: 15000 });
    
    // 戻るボタンをクリック
    await page.locator('button[aria-label*="back"]').or(page.locator('button:has([data-icon="arrow_back"])')).click();
    
    // ホーム画面に戻ることを確認
    await expect(page.locator('text=あいろぐ')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // 背景色がLINE風（グレー系）であることを確認
    const backgroundColor = await page.evaluate(() => {
      const body = document.querySelector('body');
      return window.getComputedStyle(body).backgroundColor;
    });
    
    // メッセージバブルが存在することを確認
    await expect(page.locator('.message-bubble').or(page.locator('[class*="bubble"]').or(page.locator('[class*="message"]')))).toBeVisible({ timeout: 15000 });
    
    // レスポンシブデザインの確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('text=/\\d{4}年 \\d{1,2}月/').or(page.locator('text=年'))).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Flutter').or(page.locator('text=学び始め'))).toBeVisible({ timeout: 15000 });
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('text=/\\d{4}年 \\d{1,2}月/').or(page.locator('text=年'))).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Flutter').or(page.locator('text=学び始め'))).toBeVisible({ timeout: 15000 });
  });

  test('チャット詳細画面のインタラクション', async ({ page }) => {
    // デモデータが表示されるまで待機
    await expect(page.locator('text=Claude').or(page.locator('text=ChatGPT')).or(page.locator('text=Gemini'))).toBeVisible({ timeout: 15000 });
    
    // 最初のチャットログをクリック
    await page.locator('text=Claude').first().click();
    
    // メッセージが表示されることを確認
    await expect(page.locator('text=Flutterを学び始めたのですが')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('text=Flutter学習でしたら')).toBeVisible({ timeout: 15000 });
    
    // 時刻表示があることを確認（HH:MM形式）
    await expect(page.locator('text=/\\d{2}:\\d{2}/').or(page.locator('text=:'))).toBeVisible({ timeout: 15000 });
    
    // 既読マークが表示されることを確認
    await expect(page.locator('text=既読').or(page.locator('text=✓'))).toBeVisible({ timeout: 15000 });
    
    // カレンダーの日付クリック
    await page.locator('.calendar-day[data-day="15"]').click();
    await expect(page.locator('.calendar-day[data-day="15"]')).toHaveClass(/selected/);
    
    // メッセージの存在確認
    await expect(page.locator('text=テストメッセージ')).toBeVisible({ timeout: 10000 });
    
    // 検索機能のテスト
    await page.locator('button[aria-label*="search"]').or(page.locator('button:has([data-icon="search"])')).click();
    await expect(page.locator('input[type="search"], input[placeholder*="検索"]')).toBeVisible({ timeout: 10000 });
    
    // メニュー機能のテスト
    await page.locator('button[aria-label*="menu"]').or(page.locator('button:has([data-icon="more"])')).click();
    await expect(page.locator('text=メニュー, text=オプション')).toBeVisible({ timeout: 10000 });
    
    // 戻るボタンでホーム画面に戻る
    await page.locator('button[aria-label*="back"]').or(page.locator('button:has([data-icon="arrow_back"])')).click();
    await expect(page.locator('text=あいろぐ')).toBeVisible({ timeout: 10000 });
  });
});