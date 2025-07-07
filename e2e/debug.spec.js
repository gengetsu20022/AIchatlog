const { test, expect } = require('@playwright/test');

test.describe('デバッグテスト', () => {
  test('ページ内容の確認', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
    
    // ページのHTMLとテキスト内容を出力
    const html = await page.content();
    const bodyText = await page.locator('body').textContent();
    
    console.log('=== PAGE HTML ===');
    console.log(html);
    console.log('=== BODY TEXT ===');
    console.log(bodyText);
    console.log('=== ALL ELEMENTS ===');
    
    // すべての可視要素を列挙
    const elements = await page.locator('*').allTextContents();
    elements.forEach((text, index) => {
      if (text.trim()) {
        console.log(`Element ${index}: "${text}"`);
      }
    });
    
    // Flutter特有の要素をチェック
    const flutterElements = await page.locator('flutter-view, flt-glass-pane, [flt-renderer]').count();
    console.log('Flutter elements count:', flutterElements);
    
    // スクリーンショットを撮影
    await page.screenshot({ path: 'debug-screenshot.png', fullPage: true });
    
    // 単純にテストを成功させる
    expect(true).toBe(true);
  });
}); 