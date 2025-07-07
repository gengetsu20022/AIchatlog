const { defineConfig, devices } = require("@playwright/test");

module.exports = defineConfig({
  testDir: "./e2e",
  timeout: 60 * 1000, // Docker環境では少し長めに設定
  expect: { timeout: 10000 },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ["html", { outputFolder: "playwright-report" }],
    ["json", { outputFile: "test-results.json" }],
    ["list"]
  ],
  use: {
    // Docker環境の場合はFLUTTER_WEB_URLを使用、ローカルの場合はlocalhost
    baseURL: process.env.FLUTTER_WEB_URL || "http://localhost:8080",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
    headless: true,
    viewport: { width: 1280, height: 720 },
    ignoreHTTPSErrors: true,
    actionTimeout: 15000, // Docker環境では少し長めに
    navigationTimeout: 45000, // Docker環境では少し長めに
  },
  projects: [
    {
      name: "chromium",
      use: { 
        ...devices["Desktop Chrome"],
        launchOptions: {
          args: [
            "--disable-web-security",
            "--disable-features=VizDisplayCompositor",
            "--no-sandbox", // Docker環境で必要
            "--disable-setuid-sandbox", // Docker環境で必要
            "--disable-dev-shm-usage", // Docker環境でメモリ不足対策
            "--disable-gpu" // Docker環境で安定性向上
          ]
        }
      }
    },
    {
      name: "firefox",
      use: { 
        ...devices["Desktop Firefox"],
        launchOptions: {
          firefoxUserPrefs: {
            "security.tls.insecure_fallback_hosts": "localhost,flutter-web"
          }
        }
      }
    },
    {
      name: "webkit",
      use: { 
        ...devices["Desktop Safari"]
      }
    },
    {
      name: "Mobile Chrome",
      use: { 
        ...devices["Pixel 5"],
        launchOptions: {
          args: [
            "--no-sandbox",
            "--disable-setuid-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu"
          ]
        }
      }
    },
    {
      name: "Mobile Safari",
      use: { 
        ...devices["iPhone 12"]
      }
    }
  ],
  // Docker環境用の追加設定
  webServer: process.env.CI ? undefined : {
    command: 'flutter build web && python3 -m http.server 8080 --directory build/web',
    port: 8080,
    reuseExistingServer: !process.env.CI,
  }
});
