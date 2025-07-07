# ==========================================
# Flutter Web本番用 Multi-stage Dockerfile
# ==========================================

# ビルドステージ
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS builder

# 作業ディレクトリを設定
WORKDIR /app

# Flutter環境設定
ENV FLUTTER_WEB=true
ENV PATH="/opt/flutter/bin:${PATH}"

# Flutter Webサポートを有効化
RUN flutter config --enable-web

# pubspec.yamlと pubspec.lockをコピー（依存関係のキャッシュ最適化）
COPY pubspec.yaml pubspec.lock ./

# 依存関係をダウンロード
RUN flutter pub get

# ソースコードをコピー
COPY . .

# Webアプリをビルド（本番用最適化）
RUN flutter build web --release \
    --dart-define=ENVIRONMENT=production \
    --web-renderer canvaskit \
    --pwa-strategy offline-first

# ==========================================
# 本番ステージ (Nginx)
# ==========================================
FROM nginx:alpine AS production

# セキュリティ: rootユーザーを使わない
RUN addgroup -g 1001 -S flutter && \
    adduser -S flutter -u 1001

# Nginxの設定をコピー
COPY nginx.conf /etc/nginx/nginx.conf

# ビルドされたWebアプリをコピー
COPY --from=builder /app/build/web /usr/share/nginx/html

# セキュリティヘッダー用の設定ファイル
COPY security-headers.conf /etc/nginx/conf.d/security-headers.conf

# ポート80を公開
EXPOSE 80

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Nginxを起動
CMD ["nginx", "-g", "daemon off;"]

# ==========================================
# 開発ステージ (Hot Reload対応)
# ==========================================
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS development

WORKDIR /app

# Flutter環境設定
ENV FLUTTER_WEB=true
ENV PATH="/opt/flutter/bin:${PATH}"

# Flutter Webサポートを有効化
RUN flutter config --enable-web

# 依存関係をインストール
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# ソースコードをコピー
COPY . .

# 開発用ポートを公開
EXPOSE 3000

# 開発サーバーを起動
CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "3000"] 