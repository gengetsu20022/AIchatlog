# PowerShell 7 設定スクリプト - Our AI Story プロジェクト用
# 実行方法: .\setup-powershell7.ps1

Write-Host "🚀 PowerShell 7 環境設定を開始します..." -ForegroundColor Green

# PowerShell 7の存在確認
$pwsh7Path = "C:\Program Files\PowerShell\7\pwsh.exe"
if (-not (Test-Path $pwsh7Path)) {
    Write-Host "❌ PowerShell 7が見つかりません。インストールしてください。" -ForegroundColor Red
    Write-Host "   インストール方法: winget install Microsoft.PowerShell" -ForegroundColor Yellow
    exit 1
}

# バージョン確認
$version = & $pwsh7Path --version
Write-Host "✅ PowerShell 7が見つかりました: $version" -ForegroundColor Green

# プロジェクト環境変数設定
Write-Host "📋 プロジェクト環境変数を設定中..." -ForegroundColor Blue

# PowerShell 7をプロジェクトのデフォルトに設定
$env:PWSH_PATH = $pwsh7Path
$env:PREFERRED_SHELL = "pwsh"

# Docker Compose用の環境変数設定
$env:COMPOSE_CONVERT_WINDOWS_PATHS = "1"
$env:COMPOSE_FORCE_WINDOWS_HOST = "1"

Write-Host "✅ 環境変数設定完了" -ForegroundColor Green

# PowerShell プロファイル設定
Write-Host "📋 PowerShell プロファイル設定中..." -ForegroundColor Blue

$profileContent = @"
# Our AI Story プロジェクト用 PowerShell プロファイル
# 自動生成日: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# プロジェクトディレクトリ
Set-Location "D:\AIchatlog"

# エイリアス設定
Set-Alias -Name pwsh7 -Value "$pwsh7Path"
Set-Alias -Name flutter-build -Value "flutter build web"
Set-Alias -Name docker-e2e -Value "docker-compose -f docker-compose.e2e.yml"

# カスタム関数
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
    Write-Host "PowerShell: `$(`$PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "Flutter: `$(flutter --version | Select-String `"Flutter`")" -ForegroundColor Yellow
    Write-Host "Docker: `$(docker --version)" -ForegroundColor Yellow
}

# 起動時メッセージ
Write-Host "🎯 Our AI Story プロジェクト環境へようこそ!" -ForegroundColor Green
Write-Host "利用可能なコマンド:" -ForegroundColor Cyan
Write-Host "  Start-E2ETest     - E2Eテスト実行" -ForegroundColor White
Write-Host "  Start-FlutterDev  - Flutter開発サーバー起動" -ForegroundColor White
Write-Host "  Show-ProjectStatus - プロジェクト状況表示" -ForegroundColor White
"@

# プロファイルファイルに書き込み
$profilePath = "PowerShell_profile.ps1"
$profileContent | Set-Content $profilePath -Encoding UTF8

Write-Host "✅ PowerShell プロファイル作成完了: $profilePath" -ForegroundColor Green

# 完了メッセージ
Write-Host ""
Write-Host "🎉 PowerShell 7 環境設定が完了しました!" -ForegroundColor Green
Write-Host "次回から以下のコマンドでPowerShell 7を起動できます:" -ForegroundColor Cyan
Write-Host "  pwsh -NoProfile -ExecutionPolicy Bypass -File PowerShell_profile.ps1" -ForegroundColor White
Write-Host ""
Write-Host "または:" -ForegroundColor Cyan
Write-Host "  & `"C:\Program Files\PowerShell\7\pwsh.exe`" -NoProfile -ExecutionPolicy Bypass -File PowerShell_profile.ps1" -ForegroundColor White

Write-Host ""
Write-Host "📋 設定内容:" -ForegroundColor Blue
Write-Host "  ✅ PowerShell 7 パス設定" -ForegroundColor Green
Write-Host "  ✅ プロジェクト環境変数" -ForegroundColor Green
Write-Host "  ✅ カスタムエイリアス・関数" -ForegroundColor Green
Write-Host "  ✅ 開発効率化コマンド" -ForegroundColor Green 