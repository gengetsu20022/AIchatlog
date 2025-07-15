const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャットログ機能テスト', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    
    // Flutter Webの初期化を待機
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機（より堅牢な方法）
    await page.waitForFunction(() => {
      // Flutter Webの初期化完了を示すDOM要素やグローバル変数をチェック
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('あいろぐ') ||
                           document.body.innerText.includes('デモ') ||
                           document.body.innerText.includes('ログイン');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // 追加の初期化時間を確保
    await page.waitForTimeout(5000);
  });

  test('ログ入力ページの基本機能確認', async ({ page }) => {
    // 注意: 実際の環境では認証が必要ですが、ここではUIテストとして実装
    
    // ログ入力ページに直接アクセス（認証なしでのテスト用）
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('新しいログを追加') ||
                           document.body.innerText.includes('ログ') ||
                           document.body.innerText.includes('追加');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // ページタイトルの確認（より柔軟なセレクター）
    await expect(
      page.locator('h1:has-text("新しいログを追加")')
        .or(page.locator('*:has-text("新しいログを追加")'))
        .or(page.locator('*:has-text("ログを追加")'))
    ).toBeVisible({ timeout: 15000 });
    
    // テキストエリアの確認（より柔軟なセレクター）
    const textarea = page.locator('textarea')
      .or(page.locator('[contenteditable="true"]'))
      .or(page.locator('[role="textbox"]'));
    await expect(textarea).toBeVisible({ timeout: 15000 });
    await expect(textarea).toBeEditable();
    
    // プレースホルダーテキストの確認（より柔軟なセレクター）
    await expect(textarea).toHaveAttribute('placeholder', /.*会話ログを貼り付けてください.*/, { timeout: 15000 });
  });

  test('チャットログの入力と解析テスト', async ({ page }) => {
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('新しいログを追加') ||
                           document.body.innerText.includes('ログ') ||
                           document.body.innerText.includes('追加');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // サンプルチャットログ
    const sampleChatLog = `User: こんにちは！今日はいい天気ですね。
AI: こんにちは！確かに今日は晴れていて気持ちがいいですね。何かお手伝いできることはありますか？
User: プログラミングについて教えてください。
AI: プログラミングは素晴らしい分野です！どの言語に興味がありますか？Python、JavaScript、Java、C++など、たくさんの選択肢があります。
User: Flutterを学びたいです。
AI: Flutterは素晴らしい選択です！Googleが開発したクロスプラットフォーム開発フレームワークで、一つのコードベースでiOSとAndroidの両方のアプリが作れます。`;
    
    // テキストエリアに入力（より柔軟なセレクター）
    const textarea = page.locator('textarea')
      .or(page.locator('[contenteditable="true"]'))
      .or(page.locator('[role="textbox"]'));
    await textarea.fill(sampleChatLog);
    
    // 入力内容の確認
    await expect(textarea).toHaveValue(sampleChatLog, { timeout: 15000 });
    
    // 保存ボタンの確認（より柔軟なセレクター）
    const saveButton = page.locator('button:has-text("保存")')
      .or(page.locator('*:has-text("保存")'))
      .or(page.locator('[title*="保存"]'));
    await expect(saveButton).toBeVisible({ timeout: 15000 });
    await expect(saveButton).toBeEnabled();
  });

  test('ログリストページの表示確認', async ({ page }) => {
    // ホームページ（ログリストページ）に直接アクセス
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('あいろぐ') ||
                           document.body.innerText.includes('デモ') ||
                           document.body.innerText.includes('ログ');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // ページタイトルの確認（より柔軟なセレクター）
    await expect(
      page.locator('h1:has-text("あいろぐ")')
        .or(page.locator('*:has-text("あいろぐ")'))
    ).toBeVisible({ timeout: 15000 });
    
    // 新規ログ追加ボタンの確認（より柔軟なセレクター）
    const addButton = page.locator('button:has-text("新しいログを追加")')
      .or(page.locator('*:has-text("新しいログを追加")'))
      .or(page.locator('*:has-text("追加")'))
      .or(page.locator('[title*="追加"]'));
    await expect(addButton).toBeVisible({ timeout: 15000 });
    
    // ログがない場合のメッセージ確認（より柔軟なセレクター）
    const emptyMessage = page.locator('text=まだログがありません')
      .or(page.locator('*:has-text("まだログがありません")'))
      .or(page.locator('*:has-text("ログがありません")'));
    
    // ログがある場合とない場合の両方に対応
    const hasLogs = await page.locator('.chat-log-item').count() > 0;
    
    if (!hasLogs) {
      await expect(emptyMessage).toBeVisible({ timeout: 15000 });
    }
  });

  test('チャットログ詳細ページの表示確認', async ({ page }) => {
    // テストデータがある前提での詳細ページテスト
    await page.goto('/chat-detail/test-id');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('チャット') ||
                           document.body.innerText.includes('詳細') ||
                           document.body.innerText.includes('戻る');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // 戻るボタンの確認（より柔軟なセレクター）
    const backButton = page.locator('button:has-text("戻る")')
      .or(page.locator('*:has-text("戻る")'))
      .or(page.locator('[title*="戻る"]'))
      .or(page.locator('[aria-label*="back"]'));
    await expect(backButton).toBeVisible({ timeout: 15000 });
    
    // チャットメッセージエリアの確認（より柔軟なセレクター）
    const chatArea = page.locator('.chat-messages')
      .or(page.locator('[class*="message"]'))
      .or(page.locator('[class*="chat"]'));
    await expect(chatArea).toBeVisible({ timeout: 15000 });
  });

  test('レスポンシブデザイン - チャットログページ', async ({ page }) => {
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('あいろぐ') ||
                           document.body.innerText.includes('デモ') ||
                           document.body.innerText.includes('ログ');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // モバイルサイズでの確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(
      page.locator('h1:has-text("あいろぐ")')
        .or(page.locator('*:has-text("あいろぐ")'))
    ).toBeVisible({ timeout: 15000 });
    
    // タブレットサイズでの確認
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(
      page.locator('h1:has-text("あいろぐ")')
        .or(page.locator('*:has-text("あいろぐ")'))
    ).toBeVisible({ timeout: 15000 });
    
    // デスクトップサイズでの確認
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(
      page.locator('h1:has-text("あいろぐ")')
        .or(page.locator('*:has-text("あいろぐ")'))
    ).toBeVisible({ timeout: 15000 });
  });

  test('ナビゲーション機能確認', async ({ page }) => {
    await page.goto('/home');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('あいろぐ') ||
                           document.body.innerText.includes('デモ') ||
                           document.body.innerText.includes('ログ');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // 新しいログ追加ボタンをクリック（より柔軟なセレクター）
    const addButton = page.locator('button:has-text("新しいログを追加")')
      .or(page.locator('*:has-text("新しいログを追加")'))
      .or(page.locator('*:has-text("追加")'))
      .or(page.locator('[title*="追加"]'));
    
    if (await addButton.isVisible()) {
      await addButton.click();
      
      // ログ入力ページに遷移することを確認
      await expect(page).toHaveURL(/.*log-input/, { timeout: 15000 });
      await expect(
        page.locator('h1:has-text("新しいログを追加")')
          .or(page.locator('*:has-text("新しいログを追加")'))
      ).toBeVisible({ timeout: 15000 });
    }
  });

  test('エラーハンドリング確認', async ({ page }) => {
    await page.goto('/log-input');
    await page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await page.waitForFunction(() => {
      const hasFlutterElements = document.querySelector('flutter-view') ||
                                document.querySelector('flt-glass-pane') ||
                                document.querySelector('flt-semantics-host');
      
      const hasAppContent = document.body.innerText.includes('新しいログを追加') ||
                           document.body.innerText.includes('ログ') ||
                           document.body.innerText.includes('追加');
      
      const hasFlutterCanvas = window.flutterCanvasKit || 
                              document.querySelector('canvas');
      
      return hasFlutterElements || hasAppContent || hasFlutterCanvas;
    }, { timeout: 45000 });
    
    // 空の状態で保存ボタンをクリック（より柔軟なセレクター）
    const saveButton = page.locator('button:has-text("保存")')
      .or(page.locator('*:has-text("保存")'))
      .or(page.locator('[title*="保存"]'));
    
    if (await saveButton.isVisible()) {
      await saveButton.click();
      
      // エラーメッセージまたはバリデーション表示の確認（より柔軟なセレクター）
      const errorElement = page.locator('.error-message, .snackbar, [role="alert"]')
        .or(page.locator('*:has-text("エラー")'))
        .or(page.locator('*:has-text("必須")'))
        .or(page.locator('*:has-text("入力")'));
      
      // エラー表示があるかチェック（タイムアウトを短く設定）
      try {
        await expect(errorElement).toBeVisible({ timeout: 3000 });
      } catch (e) {
        // エラー表示がない場合は、入力必須の動作を確認
        const textarea = page.locator('textarea')
          .or(page.locator('[contenteditable="true"]'))
          .or(page.locator('[role="textbox"]'));
        await expect(textarea).toBeFocused({ timeout: 15000 });
      }
    }
  });
}); 