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