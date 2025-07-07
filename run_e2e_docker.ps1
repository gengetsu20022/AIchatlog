# AIlog Docker E2E Test Script (Windows PowerShell)
# Solves yesterday's issues (port conflicts, server startup problems) with Docker environment

param(
    [switch]$Build,
    [switch]$Test,
    [switch]$Clean,
    [switch]$Logs,
    [switch]$Report,
    [switch]$Stop,
    [string]$Browser = "",
    [switch]$Help
)

function Write-Info($Message) {
    Write-Host $Message -ForegroundColor Blue
}

function Write-Success($Message) {
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host $Message -ForegroundColor Red
}

function Show-Help {
    Write-Info "AIlog Docker E2E Test Script"
    Write-Host "======================================"
    Write-Host ""
    Write-Host "Usage: .\run_e2e_docker.ps1 [Options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Build          Build Docker images"
    Write-Host "  -Test           Run E2E tests"
    Write-Host "  -Clean          Clean Docker environment"
    Write-Host "  -Logs           Show Docker logs"
    Write-Host "  -Report         Show test report"
    Write-Host "  -Stop           Stop running containers"
    Write-Host "  -Browser NAME   Test specific browser (chromium, firefox, webkit)"
    Write-Host "  -Help           Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\run_e2e_docker.ps1 -Build -Test"
    Write-Host "  .\run_e2e_docker.ps1 -Test -Browser chromium"
    Write-Host "  .\run_e2e_docker.ps1 -Clean"
}

function Test-DockerEnvironment {
    Write-Info "Checking Docker environment..."
    
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not found"
        }
        Write-Success "Docker: $dockerVersion"
        
        $composeVersion = docker-compose --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose not found"
        }
        Write-Success "Docker Compose: $composeVersion"
        
        return $true
    }
    catch {
        Write-Error "Docker environment error: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "Docker installation required:"
        Write-Host "https://docs.docker.com/desktop/install/windows/"
        return $false
    }
}

function Test-RequiredFiles {
    Write-Info "Checking required files..."
    
    $requiredFiles = @(
        "docker-compose.e2e.yml",
        "Dockerfile.playwright",
        "docker-entrypoint-playwright.sh",
        "playwright.config.js",
        "package.json"
    )
    
    foreach ($file in $requiredFiles) {
        if (!(Test-Path $file)) {
            Write-Error "Required file not found: $file"
            return $false
        }
    }
    
    if (!(Test-Path "e2e")) {
        Write-Error "e2e directory not found"
        return $false
    }
    
    Write-Success "Required files check completed"
    return $true
}

function Build-DockerImages {
    Write-Info "Building Docker images..."
    
    try {
        docker-compose -f docker-compose.e2e.yml build --no-cache
        if ($LASTEXITCODE -ne 0) {
            throw "Docker build failed"
        }
        Write-Success "Docker image build completed"
        return $true
    }
    catch {
        Write-Error "Build error: $($_.Exception.Message)"
        return $false
    }
}

function Start-E2ETests {
    param([string]$BrowserName)
    
    Write-Info "Running E2E tests..."
    
    try {
        # Stop existing containers
        docker-compose -f docker-compose.e2e.yml down 2>$null
        
        # Set environment variables
        $env:COMPOSE_PROJECT_NAME = "ailog-e2e"
        
        if ($BrowserName) {
            Write-Warning "Browser specified: $BrowserName"
            docker-compose -f docker-compose.e2e.yml run --rm playwright-tests npx playwright test --project="$BrowserName" --reporter=html
        } else {
            Write-Warning "Running tests on all browsers"
            docker-compose -f docker-compose.e2e.yml up --abort-on-container-exit
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "E2E tests completed"
            return $true
        } else {
            Write-Warning "Tests failed (check report for details)"
            return $false
        }
    }
    catch {
        Write-Error "Test execution error: $($_.Exception.Message)"
        return $false
    }
    finally {
        # Cleanup
        docker-compose -f docker-compose.e2e.yml down 2>$null
    }
}

function Show-Logs {
    Write-Info "Showing Docker logs..."
    docker-compose -f docker-compose.e2e.yml logs -f
}

function Show-TestReport {
    Write-Info "Checking test report..."
    
    if (Test-Path "playwright-report/index.html") {
        Write-Success "HTML report found"
        Write-Host "Opening report: playwright-report/index.html"
        Start-Process "playwright-report/index.html"
    } else {
        Write-Warning "HTML report not found"
        Write-Host "Run tests first: .\run_e2e_docker.ps1 -Test"
    }
    
    if (Test-Path "test-results") {
        $resultFiles = Get-ChildItem "test-results" -Recurse
        if ($resultFiles.Count -gt 0) {
            Write-Info "Test result files:"
            $resultFiles | ForEach-Object { Write-Host "  - $($_.FullName)" }
        }
    }
}

function Stop-DockerEnvironment {
    Write-Info "Stopping Docker environment..."
    docker-compose -f docker-compose.e2e.yml down
    Write-Success "Docker environment stopped"
}

function Clean-DockerEnvironment {
    Write-Info "Cleaning Docker environment..."
    
    # Stop and remove containers
    docker-compose -f docker-compose.e2e.yml down --volumes --remove-orphans
    
    # Remove unused images
    docker image prune -f
    
    # Remove test result directories
    if (Test-Path "playwright-report") {
        Remove-Item "playwright-report" -Recurse -Force
        Write-Host "  - playwright-report removed"
    }
    if (Test-Path "test-results") {
        Remove-Item "test-results" -Recurse -Force
        Write-Host "  - test-results removed"
    }
    
    Write-Success "Cleanup completed"
}

function Main {
    Write-Info "AIlog Docker E2E Test Environment"
    Write-Host "======================================"
    
    # Show help if no options or Help specified
    if ($Help -or (!$Build -and !$Test -and !$Clean -and !$Logs -and !$Report -and !$Stop)) {
        Show-Help
        return
    }
    
    # Check Docker environment
    if (!(Test-DockerEnvironment)) {
        return
    }
    
    # Check required files
    if (!(Test-RequiredFiles)) {
        return
    }
    
    # Execute operations
    try {
        if ($Clean) {
            Clean-DockerEnvironment
        }
        
        if ($Stop) {
            Stop-DockerEnvironment
        }
        
        if ($Build) {
            if (!(Build-DockerImages)) {
                return
            }
        }
        
        if ($Test) {
            if (!(Start-E2ETests -BrowserName $Browser)) {
                return
            }
        }
        
        if ($Logs) {
            Show-Logs
        }
        
        if ($Report) {
            Show-TestReport
        }
        
        Write-Success "Operation completed"
    }
    catch {
        Write-Error "Unexpected error: $($_.Exception.Message)"
    }
}

# Execute script
Main 