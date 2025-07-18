export class HomePage {
  constructor(page) {
    this.page = page;
    
    // 要素のロケーターをここで一元管理
    this.title = page.getByRole('heading', { name: 'あいろぐ' });
    this.loginButton = page.getByRole('button', { name: 'ログイン' });
    this.addNewChatButton = page.getByRole('button', { name: '新しい会話を追加' });
    this.demoBadge = page.getByRole('button', { name: 'デモ' }).or(page.locator('[data-key="demo-badge"]'));
    this.demoInfo = page.locator('[data-key="demo-info"]').or(page.getByText('これはデモ画面です'));
    this.chatLogList = page.locator('[data-key="chat-log-list"]');
  }

  // ページ上の操作をメソッドとして定義
  async goto() {
    await this.page.goto('/');
    await this.page.waitForLoadState('networkidle');
    
    // Flutter アプリケーションの読み込み完了を待機
    await this.page.waitForFunction(() => {
      return window.flutterCanvasKit || 
             document.querySelector('flutter-view') ||
             document.querySelector('flt-glass-pane') ||
             document.querySelector('[data-key]') ||
             document.body.innerText.includes('あいろぐ') ||
             document.body.innerText.includes('デモ');
    }, { timeout: 30000 });
    
    // アプリのメインタイトルが表示されるまで待機（ロード完了の指標）
    await this.title.toBeVisible({ timeout: 45000 });
  }

  async getChatItem(name) {
    // 動的に要素を探すメソッド
    return this.page.getByRole('button', { name: new RegExp(name, 'i') });
  }

  async clickChatItem(name) {
    const chatItem = await this.getChatItem(name);
    await chatItem.first().click();
  }

  async clickLogin() {
    await this.loginButton.click();
  }

  async clickAddNewChat() {
    await this.addNewChatButton.click();
  }

  async isDemoMode() {
    return await this.demoBadge.isVisible();
  }
} 