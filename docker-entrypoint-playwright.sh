#!/bin/bash

# Playwright E2Eテスト エントリーポイントスクリプト

set -e

echo "🚀 Playwright E2Eテスト環境を開始します"
echo "======================================"

# カラー出力設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 環境変数設定
FLUTTER_WEB_URL=${FLUTTER_WEB_URL:-"http://flutter-web:8080"}
MAX_WAIT_TIME=${MAX_WAIT_TIME:-300}

echo -e "${BLUE}📋 環境設定${NC}"
echo "  Flutter Web URL: $FLUTTER_WEB_URL"
echo "  最大待機時間: ${MAX_WAIT_TIME}秒"

# Flutter Webサーバーの起動待機
echo -e "${YELLOW}⏳ Flutter Webサーバーの起動を待機中...${NC}"
wait_count=0
while ! curl -f "$FLUTTER_WEB_URL" >/dev/null 2>&1; do
    if [ $wait_count -ge $MAX_WAIT_TIME ]; then
        echo -e "${RED}❌ Flutter Webサーバーが起動しませんでした（タイムアウト: ${MAX_WAIT_TIME}秒）${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}   待機中... (${wait_count}/${MAX_WAIT_TIME}秒)${NC}"
    sleep 2
    wait_count=$((wait_count + 2))
done

echo -e "${GREEN}✅ Flutter Webサーバーが起動しました${NC}"

# テスト実行前の最終チェック
echo -e "${BLUE}🔍 テスト実行前チェック${NC}"
echo "  Node.js: $(node --version)"
echo "  npm: $(npm --version)"
echo "  Playwright: $(npx playwright --version)"

# Flutter Web サーバーの詳細チェック
echo -e "${BLUE}🌐 Flutter Web サーバー詳細チェック${NC}"
curl_response=$(curl -s -o /dev/null -w "%{http_code}" "$FLUTTER_WEB_URL" || echo "000")
if [ "$curl_response" = "200" ]; then
    echo -e "${GREEN}✅ HTTP 200 OK - サーバー正常応答${NC}"
else
    echo -e "${RED}❌ HTTP $curl_response - サーバー応答異常${NC}"
    echo -e "${YELLOW}🔍 デバッグ情報:${NC}"
    curl -v "$FLUTTER_WEB_URL" || true
    exit 1
fi

# Playwrightの設定確認
if [ ! -f "playwright.config.js" ]; then
    echo -e "${RED}❌ playwright.config.jsが見つかりません${NC}"
    exit 1
fi

# テストファイルの存在確認
if [ ! -d "e2e" ]; then
    echo -e "${RED}❌ e2eディレクトリが見つかりません${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 事前チェック完了${NC}"

# テスト実行
echo -e "${BLUE}🧪 E2Eテストを実行中...${NC}"
echo "======================================"

# タイムアウト監視を追加
TIMEOUT_DURATION=${TEST_TIMEOUT:-300}  # デフォルト5分
echo -e "${YELLOW}⏰ テストタイムアウト: ${TIMEOUT_DURATION}秒${NC}"

# 引数が渡された場合はそれを実行、そうでなければデフォルトのテスト実行
if [ $# -eq 0 ]; then
    # デフォルト: 全テスト実行（HTMLレポート付き）
    timeout ${TIMEOUT_DURATION} npx playwright test --reporter=html
    test_exit_code=$?
    
    # タイムアウトチェック
    if [ $test_exit_code -eq 124 ]; then
        echo -e "${RED}❌ テストがタイムアウトしました（${TIMEOUT_DURATION}秒）${NC}"
        echo -e "${YELLOW}💡 対処法:${NC}"
        echo "  1. MAX_WAIT_TIME を延長してください"
        echo "  2. Flutter Web ビルド時間を確認してください"
        echo "  3. テストケースの複雑さを見直してください"
        exit 124
    fi
else
    # 引数が渡された場合はそれを実行
    timeout ${TIMEOUT_DURATION} "$@"
    test_exit_code=$?
    
    if [ $test_exit_code -eq 124 ]; then
        echo -e "${RED}❌ コマンドがタイムアウトしました（${TIMEOUT_DURATION}秒）${NC}"
        exit 124
    fi
fi

# テスト結果の確認
if [ $test_exit_code -eq 0 ]; then
    echo -e "${GREEN}✅ 全てのテストが成功しました${NC}"
else
    echo -e "${RED}❌ テストが失敗しました（終了コード: $test_exit_code）${NC}"
    
    # エラー詳細情報の表示
    echo -e "${YELLOW}🔍 エラー詳細情報:${NC}"
    if [ -f "test-results.json" ]; then
        echo "  - test-results.json が生成されました"
        # 失敗したテストの概要を表示
        if command -v jq >/dev/null 2>&1; then
            failed_count=$(jq '.suites[].suites[]?.specs[]?.tests[]? | select(.results[].status == "failed") | length' test-results.json 2>/dev/null | wc -l || echo "0")
            echo "  - 失敗テスト数: $failed_count"
        fi
    fi
    
    if [ -d "test-results" ]; then
        result_files=$(find test-results -name "*.png" -o -name "*.webm" | wc -l)
        echo "  - スクリーンショット/動画: ${result_files}件"
    fi
fi

# HTMLレポートの場所を表示
if [ -d "playwright-report" ]; then
    echo -e "${BLUE}📊 HTMLレポートが生成されました: playwright-report/index.html${NC}"
fi

# スクリーンショット・動画の場所を表示
if [ -d "test-results" ]; then
    echo -e "${BLUE}📸 テスト結果（スクリーンショット・動画）: test-results/${NC}"
fi

exit $test_exit_code 