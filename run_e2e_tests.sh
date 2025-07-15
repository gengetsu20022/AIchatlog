#!/bin/bash

# あいろぐ E2Eテスト実行スクリプト
# Playwright + GitHub Actions テスト環境

set -e

echo "🚀 あいろぐ E2Eテスト実行スクリプト"
echo "=================================="

# カラー出力設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ表示関数
show_help() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       依存関係をインストール"
    echo "  -b, --build         Flutter Webをビルド"
    echo "  -t, --test          テストを実行"
    echo "  -r, --report        テストレポートを表示"
    echo "  -d, --docker        Dockerでテストを実行"
    echo "  -c, --clean         キャッシュをクリア"
    echo "  --headed            ヘッドレスモードを無効にして実行"
    echo "  --browser BROWSER   特定のブラウザでテスト実行 (chromium, firefox, webkit)"
    echo "  --mobile            モバイルテストのみ実行"
    echo ""
    echo "例:"
    echo "  $0 -i -b -t          # 依存関係インストール → ビルド → テスト実行"
    echo "  $0 --browser firefox # Firefoxのみでテスト実行"
    echo "  $0 --mobile          # モバイルテストのみ実行"
    echo "  $0 -d                # Dockerでテスト実行"
}

# 依存関係インストール
install_dependencies() {
    echo -e "${BLUE}📦 依存関係をインストール中...${NC}"
    
    # Node.js依存関係
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ package.jsonが見つかりません${NC}"
        exit 1
    fi
    
    npm ci
    
    # Playwrightブラウザインストール
    npx playwright install --with-deps
    
    # Flutter依存関係
    flutter pub get
    
    echo -e "${GREEN}✅ 依存関係のインストール完了${NC}"
}

# Flutter Webビルド
build_flutter() {
    echo -e "${BLUE}🔨 Flutter Webをビルド中...${NC}"
    
    flutter build web --release
    
    echo -e "${GREEN}✅ Flutter Webビルド完了${NC}"
}

# テスト実行
run_tests() {
    local browser="$1"
    local headed="$2"
    local mobile="$3"
    
    echo -e "${BLUE}🧪 E2Eテストを実行中...${NC}"
    
    # ベースコマンド
    local cmd="npx playwright test"
    
    # ブラウザ指定
    if [ ! -z "$browser" ]; then
        cmd="$cmd --project=$browser"
        echo -e "${YELLOW}🌐 ブラウザ: $browser${NC}"
    fi
    
    # モバイルテスト
    if [ "$mobile" = "true" ]; then
        cmd="npx playwright test --project='Mobile Chrome' --project='Mobile Safari'"
        echo -e "${YELLOW}📱 モバイルテストを実行${NC}"
    fi
    
    # ヘッドレスモード
    if [ "$headed" = "true" ]; then
        cmd="$cmd --headed"
        echo -e "${YELLOW}👁️  ヘッドレスモード無効${NC}"
    fi
    
    # テスト実行
    eval $cmd
    
    echo -e "${GREEN}✅ テスト実行完了${NC}"
}

# レポート表示
show_report() {
    echo -e "${BLUE}📊 テストレポートを表示中...${NC}"
    
    if [ -d "playwright-report" ]; then
        npx playwright show-report
    else
        echo -e "${YELLOW}⚠️  レポートが見つかりません。先にテストを実行してください。${NC}"
    fi
}

# Dockerでテスト実行
run_docker_tests() {
    echo -e "${BLUE}🐳 Dockerでテストを実行中...${NC}"
    
    # Docker Composeファイルの確認
    if [ ! -f "docker-compose.playwright.yml" ]; then
        echo -e "${RED}❌ docker-compose.playwright.ymlが見つかりません${NC}"
        exit 1
    fi
    
    # 既存のコンテナを停止・削除
    echo -e "${YELLOW}🧹 既存のコンテナをクリーンアップ中...${NC}"
    docker-compose -f docker-compose.playwright.yml down --volumes --remove-orphans 2>/dev/null || true
    
    # Docker環境でテスト実行
    echo -e "${YELLOW}🚀 Dockerコンテナを起動中...${NC}"
    docker-compose -f docker-compose.playwright.yml up --build --abort-on-container-exit
    
    # コンテナ停止とクリーンアップ
    echo -e "${YELLOW}🧹 コンテナをクリーンアップ中...${NC}"
    docker-compose -f docker-compose.playwright.yml down --volumes --remove-orphans
    
    echo -e "${GREEN}✅ Dockerテスト完了${NC}"
}

# キャッシュクリア
clean_cache() {
    echo -e "${BLUE}🧹 キャッシュをクリア中...${NC}"
    
    # Node.jsキャッシュ
    if [ -d "node_modules" ]; then
        rm -rf node_modules
        echo "   - node_modules削除"
    fi
    
    # Playwrightキャッシュ
    if [ -d "test-results" ]; then
        rm -rf test-results
        echo "   - test-results削除"
    fi
    
    if [ -d "playwright-report" ]; then
        rm -rf playwright-report
        echo "   - playwright-report削除"
    fi
    
    # Flutterキャッシュ
    flutter clean
    echo "   - Flutterキャッシュクリア"
    
    # Dockerキャッシュクリア
    echo -e "${YELLOW}🐳 Dockerキャッシュもクリアしますか？ (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        docker system prune -f
        echo "   - Dockerキャッシュクリア"
    fi
    
    echo -e "${GREEN}✅ キャッシュクリア完了${NC}"
}

# メイン処理
main() {
    local install=false
    local build=false
    local test=false
    local report=false
    local docker=false
    local clean=false
    local headed=false
    local browser=""
    local mobile=false
    
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--install)
                install=true
                shift
                ;;
            -b|--build)
                build=true
                shift
                ;;
            -t|--test)
                test=true
                shift
                ;;
            -r|--report)
                report=true
                shift
                ;;
            -d|--docker)
                docker=true
                shift
                ;;
            -c|--clean)
                clean=true
                shift
                ;;
            --headed)
                headed=true
                shift
                ;;
            --browser)
                browser="$2"
                shift 2
                ;;
            --mobile)
                mobile=true
                shift
                ;;
            *)
                echo -e "${RED}❌ 不明なオプション: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 引数が何も指定されていない場合のデフォルト動作
    if [ "$install" = false ] && [ "$build" = false ] && [ "$test" = false ] && [ "$report" = false ] && [ "$docker" = false ] && [ "$clean" = false ]; then
        echo -e "${YELLOW}💡 オプションが指定されていません。ヘルプを表示します。${NC}"
        show_help
        exit 0
    fi
    
    # 処理実行
    if [ "$clean" = true ]; then
        clean_cache
    fi
    
    if [ "$docker" = true ]; then
        run_docker_tests
        exit 0
    fi
    
    if [ "$install" = true ]; then
        install_dependencies
    fi
    
    if [ "$build" = true ]; then
        build_flutter
    fi
    
    if [ "$test" = true ]; then
        run_tests "$browser" "$headed" "$mobile"
    fi
    
    if [ "$report" = true ]; then
        show_report
    fi
}

# スクリプト実行
main "$@" 