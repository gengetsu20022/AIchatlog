const { test, expect } = require('@playwright/test');

test.describe('あいろぐ - チャット詳細画面デモテスト', () => {
  test('LINE風チャット詳細画面のデモ', async ({ page }) => {
    // デモページのHTMLコンテンツを設定
    await page.setContent(`
      <!DOCTYPE html>
      <html lang="ja">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>あいろぐ - チャット詳細画面デモ</title>
          <style>
              :root {
                  --primary: #10b981;
                  --background: #F5F5F5;
                  --header-bg: #F5F0E8;
                  --text-primary: #2D2A26;
              }
              * { box-sizing: border-box; margin: 0; padding: 0; }
              body {
                  font-family: 'Noto Sans JP', sans-serif;
                  background: var(--background);
                  color: var(--text-primary);
                  height: 100vh;
                  overflow: hidden;
              }
              .app-bar {
                  background: var(--header-bg);
                  padding: 12px 16px;
                  display: flex;
                  justify-content: space-between;
                  align-items: center;
                  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.06);
              }
              .app-title {
                  display: flex;
                  align-items: center;
                  gap: 12px;
              }
              .ai-avatar {
                  width: 36px;
                  height: 36px;
                  border-radius: 50%;
                  background: var(--primary);
                  color: white;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-weight: bold;
                  font-size: 16px;
              }
              .ai-name {
                  font-size: 18px;
                  font-weight: 600;
              }
              .calendar-widget {
                  background: linear-gradient(to bottom, var(--header-bg), rgba(245, 240, 232, 0.8));
                  padding: 16px;
              }
              .calendar-header {
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  gap: 16px;
                  margin-bottom: 12px;
              }
              .calendar-title {
                  font-size: 16px;
                  font-weight: bold;
              }
              .calendar-grid {
                  display: grid;
                  grid-template-columns: repeat(7, 1fr);
                  gap: 2px;
              }
              .calendar-day-header {
                  text-align: center;
                  font-size: 12px;
                  font-weight: bold;
                  padding: 8px 4px;
              }
              .calendar-day {
                  aspect-ratio: 1.2;
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  justify-content: center;
                  font-size: 14px;
                  cursor: pointer;
                  border-radius: 8px;
                  margin: 2px;
              }
              .calendar-day.selected {
                  background: var(--primary);
                  color: white;
                  font-weight: bold;
              }
              .chat-container {
                  background: white;
                  flex: 1;
                  display: flex;
                  flex-direction: column;
                  overflow: hidden;
              }
              .chat-messages {
                  flex: 1;
                  overflow-y: auto;
                  padding: 12px;
              }
              .message {
                  display: flex;
                  margin-bottom: 8px;
                  align-items: flex-end;
              }
              .message.user {
                  flex-direction: row-reverse;
              }
              .message-avatar {
                  width: 36px;
                  height: 36px;
                  border-radius: 50%;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-weight: bold;
                  font-size: 14px;
                  margin: 0 8px;
              }
              .message.ai .message-avatar {
                  background: rgba(16, 185, 129, 0.1);
                  color: var(--primary);
              }
              .message-content {
                  max-width: 70%;
                  display: flex;
                  flex-direction: column;
              }
              .message.user .message-content {
                  align-items: flex-end;
              }
              .message-bubble {
                  padding: 8px 14px;
                  border-radius: 16px;
                  font-size: 15px;
                  line-height: 1.4;
                  margin-bottom: 2px;
              }
              .message.ai .message-bubble {
                  background: white;
                  border-bottom-left-radius: 4px;
              }
              .message.user .message-bubble {
                  background: var(--primary);
                  color: white;
                  border-bottom-right-radius: 4px;
              }
              .message-time {
                  font-size: 11px;
                  color: #9ca3af;
                  padding: 0 4px;
              }
              .message-status {
                  font-size: 11px;
                  color: #9ca3af;
                  margin-left: 8px;
              }
              .main-layout {
                  display: flex;
                  flex-direction: column;
                  height: 100vh;
              }
              .content-area {
                  flex: 1;
                  display: flex;
                  flex-direction: column;
                  overflow: hidden;
              }
          </style>
      </head>
      <body>
          <div class="main-layout">
              <div class="app-bar">
                  <div class="app-title">
                      <div class="ai-avatar">C</div>
                      <div class="ai-name">Claude</div>
                  </div>
                  <div class="app-actions">
                      <button class="icon-button">
                          <span>🔍</span>
                      </button>
                      <button class="icon-button">
                          <span>⋮</span>
                      </button>
                  </div>
              </div>

              <div class="content-area">
                  <div class="calendar-widget">
                      <div class="calendar-header">
                          <button class="calendar-nav" onclick="changeMonth(-1)">
                              <span>‹</span>
                          </button>
                          <div class="calendar-title" id="calendarTitle">2025年 1月</div>
                          <button class="calendar-nav" onclick="changeMonth(1)">
                              <span>›</span>
                          </button>
                      </div>
                      
                      <div class="calendar-grid">
                          <div class="calendar-day-header">日</div>
                          <div class="calendar-day-header">月</div>
                          <div class="calendar-day-header">火</div>
                          <div class="calendar-day-header">水</div>
                          <div class="calendar-day-header">木</div>
                          <div class="calendar-day-header">金</div>
                          <div class="calendar-day-header">土</div>
                          
                          <div class="calendar-day"></div>
                          <div class="calendar-day"></div>
                          <div class="calendar-day"></div>
                          <div class="calendar-day">1</div>
                          <div class="calendar-day">2</div>
                          <div class="calendar-day">3</div>
                          <div class="calendar-day">4</div>
                          <div class="calendar-day">5</div>
                          <div class="calendar-day">6</div>
                          <div class="calendar-day">7</div>
                          <div class="calendar-day">8</div>
                          <div class="calendar-day">9</div>
                          <div class="calendar-day">10</div>
                          <div class="calendar-day">11</div>
                          <div class="calendar-day">12</div>
                          <div class="calendar-day">13</div>
                          <div class="calendar-day">14</div>
                          <div class="calendar-day">15</div>
                          <div class="calendar-day">16</div>
                          <div class="calendar-day">17</div>
                          <div class="calendar-day">18</div>
                          <div class="calendar-day">19</div>
                          <div class="calendar-day">20</div>
                          <div class="calendar-day">21</div>
                          <div class="calendar-day">22</div>
                          <div class="calendar-day">23</div>
                          <div class="calendar-day">24</div>
                          <div class="calendar-day">25</div>
                          <div class="calendar-day">26</div>
                          <div class="calendar-day">27</div>
                          <div class="calendar-day">28</div>
                          <div class="calendar-day">29</div>
                          <div class="calendar-day">30</div>
                          <div class="calendar-day selected">31</div>
                      </div>
                  </div>

                  <div class="chat-container">
                      <div class="chat-messages">
                          <div class="message user">
                              <div class="message-content">
                                  <div class="message-bubble">
                                      Flutterを学び始めたのですが、どこから始めるのがおすすめですか？
                                  </div>
                                  <div class="message-time">14:30</div>
                              </div>
                              <div class="message-status">既読</div>
                          </div>

                          <div class="message ai">
                              <div class="message-avatar">C</div>
                              <div class="message-content">
                                  <div class="message-bubble">
                                      Flutter学習でしたら、まず公式ドキュメントの「Get Started」から始めることをおすすめします。
                                  </div>
                                  <div class="message-time">14:31</div>
                              </div>
                          </div>

                          <div class="message user">
                              <div class="message-content">
                                  <div class="message-bubble">
                                      ありがとうございます！DartとFlutterの関係についても教えてください。
                                  </div>
                                  <div class="message-time">14:32</div>
                              </div>
                              <div class="message-status">既読</div>
                          </div>

                          <div class="message ai">
                              <div class="message-avatar">C</div>
                              <div class="message-content">
                                  <div class="message-bubble">
                                      DartはFlutterアプリケーションを書くためのプログラミング言語です。Googleが開発したもので、FlutterフレームワークはDart言語で書かれています。
                                  </div>
                                  <div class="message-time">14:33</div>
                              </div>
                          </div>
                      </div>
                  </div>
              </div>
          </div>

          <script>
              let currentMonth = 1;
              let currentYear = 2025;

              function changeMonth(direction) {
                  currentMonth += direction;
                  if (currentMonth > 12) {
                      currentMonth = 1;
                      currentYear++;
                  } else if (currentMonth < 1) {
                      currentMonth = 12;
                      currentYear--;
                  }
                  
                  document.getElementById('calendarTitle').textContent = \`\${currentYear}年 \${currentMonth}月\`;
              }

              document.querySelectorAll('.calendar-day').forEach(day => {
                  day.addEventListener('click', function() {
                      if (this.textContent.trim()) {
                          document.querySelectorAll('.calendar-day').forEach(d => d.classList.remove('selected'));
                          this.classList.add('selected');
                      }
                  });
              });
          </script>
      </body>
      </html>
    `);
    
    // ページタイトルを確認
    await expect(page).toHaveTitle('あいろぐ - チャット詳細画面デモ');
    
    // AI名が表示されることを確認
    await expect(page.locator('.ai-name')).toHaveText('Claude');
    
    // AIアバターが表示されることを確認
    await expect(page.locator('.ai-avatar')).toBeVisible();
    
    // カレンダーウィジェットが表示されることを確認
    await expect(page.locator('#calendarTitle')).toHaveText('2025年 1月');
    
    // 曜日ヘッダーが表示されることを確認
    await expect(page.locator('.calendar-day-header')).toHaveCount(7);
    
    // メッセージが表示されることを確認
    await expect(page.locator('text=Flutterを学び始めたのですが')).toBeVisible();
    await expect(page.locator('text=Flutter学習でしたら')).toBeVisible();
    
    // 時刻表示があることを確認
    await expect(page.locator('text=14:30')).toBeVisible();
    await expect(page.locator('text=14:31')).toBeVisible();
    
    // 既読マークが表示されることを確認
    await expect(page.locator('text=既読')).toBeVisible();
    
    // カレンダーの月切り替えが動作することを確認
    const currentMonth = await page.locator('#calendarTitle').textContent();
    await page.locator('button:has-text("›")').click();
    const newMonth = await page.locator('#calendarTitle').textContent();
    expect(newMonth).not.toBe(currentMonth);
    
    // レスポンシブデザインの確認
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(page.locator('.ai-name')).toBeVisible();
    await expect(page.locator('#calendarTitle')).toBeVisible();
    
    await page.setViewportSize({ width: 1280, height: 720 });
    await expect(page.locator('.ai-name')).toBeVisible();
    await expect(page.locator('#calendarTitle')).toBeVisible();
  });

  test('チャット詳細画面のインタラクション', async ({ page }) => {
    // 同様のHTMLコンテンツを設定（簡略版）
    await page.setContent(`
      <!DOCTYPE html>
      <html>
      <head>
          <title>チャット詳細テスト</title>
          <style>
              .calendar-day { padding: 8px; cursor: pointer; }
              .calendar-day.selected { background: #10b981; color: white; }
              .message-bubble { padding: 8px; margin: 4px; border-radius: 8px; }
              .message.user .message-bubble { background: #10b981; color: white; }
              .message.ai .message-bubble { background: white; }
          </style>
      </head>
      <body>
          <div id="calendarTitle">2025年 1月</div>
          <div class="calendar-day" data-day="15">15</div>
          <div class="calendar-day selected" data-day="31">31</div>
          
          <div class="message user">
              <div class="message-bubble">テストメッセージ</div>
          </div>
          
          <div class="message ai">
              <div class="message-bubble">AIの返信</div>
          </div>
      </body>
      </html>
    `);
    
    // カレンダーの日付クリック
    await page.locator('.calendar-day[data-day="15"]').click();
    await expect(page.locator('.calendar-day[data-day="15"]')).toHaveClass(/selected/);
    
    // メッセージの存在確認
    await expect(page.locator('text=テストメッセージ')).toBeVisible();
    await expect(page.locator('text=AIの返信')).toBeVisible();
  });
});