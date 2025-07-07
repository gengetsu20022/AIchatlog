const { test, expect } = require('@playwright/test');

test.describe('シンプルテスト', () => {
  test('基本的なページアクセス', async ({ page }) => {
    // テスト用の簡単なHTMLページを作成
    await page.setContent(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>テストページ</title>
        </head>
        <body>
          <h1>あいろぐ</h1>
          <p>テスト用ページ</p>
          <button id="test-button">テストボタン</button>
        </body>
      </html>
    `);
    
    // ページタイトルを確認
    await expect(page).toHaveTitle('テストページ');
    
    // 見出しを確認
    await expect(page.locator('h1')).toHaveText('あいろぐ');
    
    // ボタンが存在することを確認
    await expect(page.locator('#test-button')).toBeVisible();
    
    // ボタンをクリック
    await page.locator('#test-button').click();
  });

  test('レスポンシブデザイン', async ({ page }) => {
    await page.setContent(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>レスポンシブテスト</title>
          <style>
            .container { 
              width: 100%; 
              max-width: 1200px; 
              margin: 0 auto; 
              padding: 20px;
            }
            @media (max-width: 768px) {
              .container { padding: 10px; }
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>レスポンシブテスト</h1>
            <p>このページはレスポンシブデザインです。</p>
          </div>
        </body>
      </html>
    `);
    
    // デスクトップサイズ
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('.container')).toBeVisible();
    
    // モバイルサイズ
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('.container')).toBeVisible();
  });
}); 