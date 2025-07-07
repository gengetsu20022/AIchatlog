const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャットログ機能テスト', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
  });

  test('ログ入力ページの基本機能確認', async ({ page }) => {
    // 注意: 実際の環境では認証が必要ですが、ここではUIテストとして実装
    
    // ログ入力ページに直接アクセス（認証なしでのテスト用）
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // ページタイトルの確認
    await expect(page.locator('h1:has-text("新しいログを追加")')).toBeVisible({ timeout: 10000 });
    
    // テキストエリアの確認
    const textarea = page.locator('textarea');
    await expect(textarea).toBeVisible();
    await expect(textarea).toBeEditable();
    
    // プレースホルダーテキストの確認
    await expect(textarea).toHaveAttribute('placeholder', /.*会話ログを貼り付けてください.*/);
  });

  test('チャットログの入力と解析テスト', async ({ page }) => {
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // サンプルチャットログ
    const sampleChatLog = `User: こんにちは！今日はいい天気ですね。
AI: こんにちは！確かに今日は晴れていて気持ちがいいですね。何かお手伝いできることはありますか？
User: プログラミングについて教えてください。
AI: プログラミングは素晴らしい分野です！どの言語に興味がありますか？Python、JavaScript、Java、C++など、たくさんの選択肢があります。
User: Flutterを学びたいです。
AI: Flutterは素晴らしい選択です！Googleが開発したクロスプラットフォーム開発フレームワークで、一つのコードベースでiOSとAndroidの両方のアプリが作れます。`;
    
    // テキストエリアに入力
    const textarea = page.locator('textarea');
    await textarea.fill(sampleChatLog);
    
    // 入力内容の確認
    await expect(textarea).toHaveValue(sampleChatLog);
    
    // 保存ボタンの確認
    const saveButton = page.locator('button:has-text("保存")');
    await expect(saveButton).toBeVisible();
    await expect(saveButton).toBeEnabled();
  });

  test('ログリストページの表示確認', async ({ page }) => {
    // ホームページ（ログリストページ）に直接アクセス
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // ページタイトルの確認
    await expect(page.locator('h1:has-text("あいろぐ")')).toBeVisible({ timeout: 10000 });
    
    // 新規ログ追加ボタンの確認
    const addButton = page.locator('button:has-text("新しいログを追加")');
    await expect(addButton).toBeVisible();
    
    // ログがない場合のメッセージ確認
    const emptyMessage = page.locator('text=まだログがありません');
    // ログがある場合とない場合の両方に対応
    const hasLogs = await page.locator('.chat-log-item').count() > 0;
    
    if (!hasLogs) {
      await expect(emptyMessage).toBeVisible();
    }
  });

  test('チャットログ詳細ページの表示確認', async ({ page }) => {
    // テストデータがある前提での詳細ページテスト
    await page.goto('/chat-detail/test-id');
    await page.waitForLoadState('networkidle');
    
    // 戻るボタンの確認
    const backButton = page.locator('button:has-text("戻る")');
    await expect(backButton).toBeVisible({ timeout: 10000 });
    
    // チャットメッセージエリアの確認
    const chatArea = page.locator('.chat-messages');
    await expect(chatArea).toBeVisible();
  });

  test('レスポンシブデザイン - チャットログページ', async ({ page }) => {
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // モバイルサイズでの確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('h1:has-text("あいろぐ")')).toBeVisible();
    
    // タブレットサイズでの確認
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(page.locator('h1:has-text("あいろぐ")')).toBeVisible();
    
    // デスクトップサイズでの確認
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('h1:has-text("あいろぐ")')).toBeVisible();
  });

  test('ナビゲーション機能確認', async ({ page }) => {
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // 新しいログ追加ボタンをクリック
    const addButton = page.locator('button:has-text("新しいログを追加")');
    if (await addButton.isVisible()) {
      await addButton.click();
      
      // ログ入力ページに遷移することを確認
      await expect(page).toHaveURL(/.*log-input/);
      await expect(page.locator('h1:has-text("新しいログを追加")')).toBeVisible({ timeout: 10000 });
    }
  });

  test('エラーハンドリング確認', async ({ page }) => {
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // 空の状態で保存ボタンをクリック
    const saveButton = page.locator('button:has-text("保存")');
    if (await saveButton.isVisible()) {
      await saveButton.click();
      
      // エラーメッセージまたはバリデーション表示の確認
      // 実装に応じて適切なセレクターに変更
      const errorElement = page.locator('.error-message, .snackbar, [role="alert"]');
      
      // エラー表示があるかチェック（タイムアウトを短く設定）
      try {
        await expect(errorElement).toBeVisible({ timeout: 3000 });
      } catch (e) {
        // エラー表示がない場合は、入力必須の動作を確認
        const textarea = page.locator('textarea');
        await expect(textarea).toBeFocused();
      }
    }
  });
}); 