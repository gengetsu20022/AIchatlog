# PowerShell 7 簡易設定スクリプト - Our AI Story プロジェクト用

Write-Host "🚀 PowerShell 7 環境設定を開始します..." -ForegroundColor Green

# PowerShell 7の存在確認
$pwsh7Path = "C:\Program Files\PowerShell\7\pwsh.exe"
if (Test-Path $pwsh7Path) {
    Write-Host "✅ PowerShell 7が見つかりました" -ForegroundColor Green
    
    # バージョン確認
    $version = & $pwsh7Path --version
    Write-Host "   バージョン: $version" -ForegroundColor Yellow
} else {
    Write-Host "❌ PowerShell 7が見つかりません" -ForegroundColor Red
    Write-Host "   インストール方法: winget install Microsoft.PowerShell" -ForegroundColor Yellow
    exit 1
}

# 環境変数設定
Write-Host "📋 環境変数を設定中..." -ForegroundColor Blue
$env:PWSH_PATH = $pwsh7Path
$env:PREFERRED_SHELL = "pwsh"
Write-Host "✅ 環境変数設定完了" -ForegroundColor Green

# プロジェクト用起動スクリプト作成
Write-Host "📝 プロジェクト用起動スクリプトを作成中..." -ForegroundColor Blue

$startScript = @'
# Our AI Story プロジェクト - PowerShell 7 起動スクリプト
Write-Host "🎯 Our AI Story プロジェクト環境" -ForegroundColor Green
Write-Host "PowerShell バージョン: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow

# プロジェクトディレクトリに移動
Set-Location "D:\AIchatlog"

# エイリアス設定
Set-Alias -Name flutter-build -Value "flutter build web"
Set-Alias -Name docker-e2e -Value "docker-compose -f docker-compose.e2e.yml"

# 便利な関数
function Start-E2ETest {
    Write-Host "🧪 E2Eテストを開始します..." -ForegroundColor Blue
    docker-compose -f docker-compose.e2e.yml up --build
}

function Start-FlutterDev {
    Write-Host "🚀 Flutter開発サーバーを開始します..." -ForegroundColor Blue
    flutter run -d web-server --web-port 8080
}

function Show-ProjectStatus {
    Write-Host "📊 プロジェクト状況" -ForegroundColor Green
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        $flutterVersion = flutter --version | Select-String "Flutter"
        Write-Host "Flutter: $flutterVersion" -ForegroundColor Yellow
    }
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $dockerVersion = docker --version
        Write-Host "Docker: $dockerVersion" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "利用可能なコマンド:" -ForegroundColor Cyan
Write-Host "  Start-E2ETest      - E2Eテスト実行" -ForegroundColor White
Write-Host "  Start-FlutterDev   - Flutter開発サーバー起動" -ForegroundColor White
Write-Host "  Show-ProjectStatus - プロジェクト状況表示" -ForegroundColor White
Write-Host ""
'@

# 起動スクリプトを保存
$startScript | Set-Content "start-pwsh7.ps1" -Encoding UTF8
Write-Host "✅ 起動スクリプト作成完了: start-pwsh7.ps1" -ForegroundColor Green

# バッチファイル作成（ダブルクリックで起動用）
$batchContent = @"
@echo off
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "start-pwsh7.ps1"
pause
"@

$batchContent | Set-Content "start-pwsh7.bat" -Encoding ASCII
Write-Host "✅ バッチファイル作成完了: start-pwsh7.bat" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 PowerShell 7 環境設定完了!" -ForegroundColor Green
Write-Host ""
Write-Host "起動方法:" -ForegroundColor Cyan
Write-Host "  1. PowerShell 7で: .\start-pwsh7.ps1" -ForegroundColor White
Write-Host "  2. バッチファイル: start-pwsh7.bat をダブルクリック" -ForegroundColor White
Write-Host "  3. 直接起動: pwsh -ExecutionPolicy Bypass -File start-pwsh7.ps1" -ForegroundColor White 