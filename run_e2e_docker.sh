#!/bin/bash

# あいろぐ Docker E2Eテスト実行スクリプト (Linux/Mac)
# 昨日の課題（ポート競合・サーバー起動問題）をDocker環境で解決

set -e

# カラー出力設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# デフォルト値
BUILD=false
TEST=false
CLEAN=false
LOGS=false
REPORT=false
STOP=false
BROWSER=""
HELP=false

# ヘルプ表示
show_help() {
    echo -e "${YELLOW}🚀 あいろぐ Docker E2Eテスト実行スクリプト${NC}"
    echo "======================================"
    echo ""
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -b, --build         Dockerイメージをビルド"
    echo "  -t, --test          E2Eテストを実行"
    echo "  -c, --clean         Docker環境をクリーンアップ"
    echo "  -l, --logs          実行中のログを表示"
    echo "  -r, --report        テストレポートを表示"
    echo "  -s, --stop          実行中のコンテナを停止"
    echo "  --browser BROWSER   特定ブラウザのみテスト (chromium, firefox, webkit)"
    echo "  -h, --help          このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 -b -t              # ビルド→テスト実行"
    echo "  $0 -t --browser chromium  # Chromiumのみテスト"
    echo "  $0 -c                 # 環境クリーンアップ"
    echo "  $0 -l                 # ログ表示"
}

# Docker環境の確認
check_docker_environment() {
    echo -e "${BLUE}🔍 Docker環境を確認中...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Dockerが見つかりません${NC}"
        echo ""
        echo "Dockerのインストールが必要です:"
        echo "https://docs.docker.com/engine/install/"
        return 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Composeが見つかりません${NC}"
        echo ""
        echo "Docker Composeのインストールが必要です:"
        echo "https://docs.docker.com/compose/install/"
        return 1
    fi
    
    local docker_version=$(docker --version)
    local compose_version=$(docker-compose --version)
    
    echo -e "${GREEN}✅ Docker: $docker_version${NC}"
    echo -e "${GREEN}✅ Docker Compose: $compose_version${NC}"
    
    return 0
}

# 必要ファイルの確認
check_required_files() {
    echo -e "${BLUE}📋 必要ファイルを確認中...${NC}"
    
    local required_files=(
        "docker-compose.e2e.yml"
        "Dockerfile.playwright"
        "docker-entrypoint-playwright.sh"
        "playwright.config.js"
        "package.json"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}❌ 必要ファイルが見つかりません: $file${NC}"
            return 1
        fi
    done
    
    if [ ! -d "e2e" ]; then
        echo -e "${RED}❌ e2eディレクトリが見つかりません${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ 必要ファイル確認完了${NC}"
    return 0
}

# Dockerイメージビルド
build_docker_images() {
    echo -e "${BLUE}🔨 Dockerイメージをビルド中...${NC}"
    
    if docker-compose -f docker-compose.e2e.yml build --no-cache; then
        echo -e "${GREEN}✅ Dockerイメージビルド完了${NC}"
        return 0
    else
        echo -e "${RED}❌ Dockerビルドが失敗しました${NC}"
        return 1
    fi
}

# E2Eテスト実行
start_e2e_tests() {
    local browser_name="$1"
    
    echo -e "${BLUE}🧪 E2Eテストを実行中...${NC}"
    
    # 既存のコンテナを停止・削除
    docker-compose -f docker-compose.e2e.yml down 2>/dev/null || true
    
    # 環境変数設定
    export COMPOSE_PROJECT_NAME="ailog-e2e"
    
    local exit_code=0
    
    if [ -n "$browser_name" ]; then
        echo -e "${YELLOW}🌐 ブラウザ指定: $browser_name${NC}"
        docker-compose -f docker-compose.e2e.yml run --rm playwright-tests npx playwright test --project="$browser_name" --reporter=html
        exit_code=$?
    else
        echo -e "${YELLOW}🌐 全ブラウザでテスト実行${NC}"
        docker-compose -f docker-compose.e2e.yml up --abort-on-container-exit
        exit_code=$?
    fi
    
    # 後片付け
    docker-compose -f docker-compose.e2e.yml down 2>/dev/null || true
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ E2Eテスト完了${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ テストが失敗しました（詳細はレポートを確認）${NC}"
        return 1
    fi
}

# ログ表示
show_logs() {
    echo -e "${BLUE}📋 Docker ログを表示中...${NC}"
    docker-compose -f docker-compose.e2e.yml logs -f
}

# テストレポート表示
show_test_report() {
    echo -e "${BLUE}📊 テストレポートを確認中...${NC}"
    
    if [ -f "playwright-report/index.html" ]; then
        echo -e "${GREEN}✅ HTMLレポートが見つかりました${NC}"
        echo "レポートの場所: playwright-report/index.html"
        
        # ブラウザでレポートを開く（OS別）
        if command -v xdg-open &> /dev/null; then
            xdg-open "playwright-report/index.html"
        elif command -v open &> /dev/null; then
            open "playwright-report/index.html"
        else
            echo "ブラウザで playwright-report/index.html を開いてください"
        fi
    else
        echo -e "${YELLOW}⚠️ HTMLレポートが見つかりません${NC}"
        echo "先にテストを実行してください: $0 -t"
    fi
    
    if [ -d "test-results" ]; then
        local result_count=$(find test-results -type f | wc -l)
        if [ $result_count -gt 0 ]; then
            echo -e "${BLUE}📸 テスト結果ファイル ($result_count 個):${NC}"
            find test-results -type f | head -10 | while read file; do
                echo "  - $file"
            done
            if [ $result_count -gt 10 ]; then
                echo "  ... 他 $((result_count - 10)) 個"
            fi
        fi
    fi
}

# Docker環境停止
stop_docker_environment() {
    echo -e "${BLUE}🛑 Docker環境を停止中...${NC}"
    docker-compose -f docker-compose.e2e.yml down
    echo -e "${GREEN}✅ Docker環境停止完了${NC}"
}

# Docker環境クリーンアップ
clean_docker_environment() {
    echo -e "${BLUE}🧹 Docker環境をクリーンアップ中...${NC}"
    
    # コンテナ停止・削除
    docker-compose -f docker-compose.e2e.yml down --volumes --remove-orphans
    
    # 未使用イメージ削除
    docker image prune -f
    
    # テスト結果ディレクトリ削除
    if [ -d "playwright-report" ]; then
        rm -rf "playwright-report"
        echo "  - playwright-report削除"
    fi
    if [ -d "test-results" ]; then
        rm -rf "test-results"
        echo "  - test-results削除"
    fi
    
    echo -e "${GREEN}✅ クリーンアップ完了${NC}"
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)
            BUILD=true
            shift
            ;;
        -t|--test)
            TEST=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -l|--logs)
            LOGS=true
            shift
            ;;
        -r|--report)
            REPORT=true
            shift
            ;;
        -s|--stop)
            STOP=true
            shift
            ;;
        --browser)
            BROWSER="$2"
            shift 2
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            echo -e "${RED}❌ 不明なオプション: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# メイン処理
main() {
    echo -e "${BLUE}🚀 あいろぐ Docker E2Eテスト環境${NC}"
    echo "======================================"
    
    # ヘルプ表示
    if [ "$HELP" = true ] || [ "$BUILD" = false ] && [ "$TEST" = false ] && [ "$CLEAN" = false ] && [ "$LOGS" = false ] && [ "$REPORT" = false ] && [ "$STOP" = false ]; then
        show_help
        return 0
    fi
    
    # Docker環境確認
    if ! check_docker_environment; then
        return 1
    fi
    
    # 必要ファイル確認
    if ! check_required_files; then
        return 1
    fi
    
    # 処理実行
    local overall_success=true
    
    if [ "$CLEAN" = true ]; then
        clean_docker_environment
    fi
    
    if [ "$STOP" = true ]; then
        stop_docker_environment
    fi
    
    if [ "$BUILD" = true ]; then
        if ! build_docker_images; then
            overall_success=false
        fi
    fi
    
    if [ "$TEST" = true ] && [ "$overall_success" = true ]; then
        if ! start_e2e_tests "$BROWSER"; then
            overall_success=false
        fi
    fi
    
    if [ "$LOGS" = true ]; then
        show_logs
    fi
    
    if [ "$REPORT" = true ]; then
        show_test_report
    fi
    
    if [ "$overall_success" = true ]; then
        echo -e "${GREEN}🎉 処理完了${NC}"
        return 0
    else
        echo -e "${RED}❌ 一部の処理でエラーが発生しました${NC}"
        return 1
    fi
}

# スクリプト実行
main "$@" 