export class LogInputPage {
  constructor(page) {
    this.page = page;
    
    // 要素のロケーターをここで一元管理
    this.title = page.getByRole('heading', { name: '会話ログを追加' }).or(page.locator('[data-key="log-input-title"]'));
    this.userNameField = page.locator('[data-key="user_name_field"]').or(page.getByRole('textbox', { name: /あなたの名前/ }));
    this.aiNameField = page.locator('[data-key="ai_name_field"]').or(page.getByRole('textbox', { name: /AIの名前/ }));
    this.chatLogField = page.locator('[data-key="chat_log_field"]').or(page.getByRole('textbox', { name: /会話ログ/ }));
    this.saveButton = page.getByRole('button', { name: '保存' });
    this.datePickerButton = page.locator('[data-key="date-picker-button"]').or(page.getByRole('button', { name: /\\d{4}\\/\\d{1,2}\\/\\d{1,2}/ }));
  }

  // ページ上の操作をメソッドとして定義
  async fillUserInfo(userName, aiName) {
    await this.userNameField.fill(userName);
    await this.aiNameField.fill(aiName);
  }

  async fillChatLog(content) {
    await this.chatLogField.fill(content);
  }

  async save() {
    await this.saveButton.click();
  }

  async selectDate(date) {
    await this.datePickerButton.click();
    // 日付選択の実装は必要に応じて追加
  }

  async isVisible() {
    return await this.title.isVisible();
  }
} 