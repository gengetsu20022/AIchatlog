# E2E Test Script for PowerShell
param(
    [switch]$Help,
    [switch]$Install, 
    [switch]$Build,
    [switch]$Test,
    [switch]$Report,
    [switch]$Docker,
    [switch]$Clean,
    [switch]$Headed,
    [string]$Browser,
    [switch]$Mobile
)

if ($Help) {
    Write-Host "あいろぐ E2Eテスト実行スクリプト" -ForegroundColor Blue
    Write-Host "=================================="
    Write-Host "使用方法:"
    Write-Host "  .\run_e2e_tests.ps1 -Install  # 依存関係インストール"
    Write-Host "  .\run_e2e_tests.ps1 -Build    # Flutter Webビルド"
    Write-Host "  .\run_e2e_tests.ps1 -Test     # テスト実行"
    Write-Host "  .\run_e2e_tests.ps1 -Report   # レポート表示"
    Write-Host "  .\run_e2e_tests.ps1 -Docker   # Dockerでテスト実行"
    Write-Host "  .\run_e2e_tests.ps1 -Clean    # キャッシュクリア"
    Write-Host "  .\run_e2e_tests.ps1 -Headed   # ヘッドレスモード無効"
    Write-Host "  .\run_e2e_tests.ps1 -Browser chromium  # 特定ブラウザでテスト"
    Write-Host "  .\run_e2e_tests.ps1 -Mobile   # モバイルテストのみ"
    exit 0
}

if ($Clean) {
    Write-Host "キャッシュをクリア中..." -ForegroundColor Blue
    
    # Node.jsキャッシュ
    if (Test-Path "node_modules") {
        Remove-Item -Recurse -Force "node_modules"
        Write-Host "   - node_modules削除" -ForegroundColor Yellow
    }
    
    # Playwrightキャッシュ
    if (Test-Path "test-results") {
        Remove-Item -Recurse -Force "test-results"
        Write-Host "   - test-results削除" -ForegroundColor Yellow
    }
    
    if (Test-Path "playwright-report") {
        Remove-Item -Recurse -Force "playwright-report"
        Write-Host "   - playwright-report削除" -ForegroundColor Yellow
    }
    
    # Flutterキャッシュ
    flutter clean
    Write-Host "   - Flutterキャッシュクリア" -ForegroundColor Yellow
    
    # Dockerキャッシュクリア
    $response = Read-Host "Dockerキャッシュもクリアしますか？ (y/N)"
    if ($response -match "^[yY]$") {
        docker system prune -f
        Write-Host "   - Dockerキャッシュクリア" -ForegroundColor Yellow
    }
    
    Write-Host "キャッシュクリア完了" -ForegroundColor Green
}

if ($Docker) {
    Write-Host "Dockerでテストを実行中..." -ForegroundColor Blue
    
    # Docker Composeファイルの確認
    if (-not (Test-Path "docker-compose.playwright.yml")) {
        Write-Host "❌ docker-compose.playwright.ymlが見つかりません" -ForegroundColor Red
        exit 1
    }
    
    # 既存のコンテナを停止・削除
    Write-Host "🧹 既存のコンテナをクリーンアップ中..." -ForegroundColor Yellow
    docker-compose -f docker-compose.playwright.yml down --volumes --remove-orphans 2>$null
    
    # Docker環境でテスト実行
    Write-Host "🚀 Dockerコンテナを起動中..." -ForegroundColor Yellow
    docker-compose -f docker-compose.playwright.yml up --build --abort-on-container-exit
    
    # コンテナ停止とクリーンアップ
    Write-Host "🧹 コンテナをクリーンアップ中..." -ForegroundColor Yellow
    docker-compose -f docker-compose.playwright.yml down --volumes --remove-orphans
    
    Write-Host "Dockerテスト完了" -ForegroundColor Green
    exit 0
}

if ($Install) {
    Write-Host "依存関係をインストール中..." -ForegroundColor Blue
    npm ci
    npx playwright install --with-deps
    flutter pub get
    Write-Host "インストール完了" -ForegroundColor Green
}

if ($Build) {
    Write-Host "Flutter Webをビルド中..." -ForegroundColor Blue
    flutter build web --release
    Write-Host "ビルド完了" -ForegroundColor Green
}

if ($Test) {
    Write-Host "テストを実行中..." -ForegroundColor Blue
    
    # ベースコマンド
    $cmd = "npx playwright test"
    
    # ブラウザ指定
    if ($Browser) {
        $cmd = "$cmd --project=$Browser"
        Write-Host "🌐 ブラウザ: $Browser" -ForegroundColor Yellow
    }
    
    # モバイルテスト
    if ($Mobile) {
        $cmd = "npx playwright test --project='Mobile Chrome' --project='Mobile Safari'"
        Write-Host "📱 モバイルテストを実行" -ForegroundColor Yellow
    }
    
    # ヘッドレスモード
    if ($Headed) {
        $cmd = "$cmd --headed"
        Write-Host "👁️  ヘッドレスモード無効" -ForegroundColor Yellow
    }
    
    # テスト実行
    Invoke-Expression $cmd
    Write-Host "テスト完了" -ForegroundColor Green
}

if ($Report) {
    Write-Host "レポートを表示中..." -ForegroundColor Blue
    if (Test-Path "playwright-report") {
        npx playwright show-report
    } else {
        Write-Host "⚠️  レポートが見つかりません。先にテストを実行してください。" -ForegroundColor Yellow
    }
}
