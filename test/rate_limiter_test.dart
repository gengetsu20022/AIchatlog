import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/services/rate_limiter.dart';

void main() {
  group('RateLimiter Tests', () {
    late RateLimiter rateLimiter;

    setUp(() {
      rateLimiter = RateLimiter();
    });

    group('RateLimitConfig', () {
      test('設定が正しく作成される', () {
        const config = RateLimitConfig(
          maxRequests: 10,
          timeWindow: Duration(minutes: 1),
          blockDuration: Duration(minutes: 5),
        );

        expect(config.maxRequests, equals(10));
        expect(config.timeWindow, equals(const Duration(minutes: 1)));
        expect(config.blockDuration, equals(const Duration(minutes: 5)));
      });
    });

    group('UserRequestHistory', () {
      test('リクエスト履歴が正しく管理される', () {
        final history = UserRequestHistory();
        
        expect(history.getRequestCount(), equals(0));
        expect(history.isBlocked(), isFalse);

        history.addRequest();
        expect(history.getRequestCount(), equals(1));

        history.block(const Duration(minutes: 1));
        expect(history.isBlocked(), isTrue);
      });

      test('古いリクエストが正しく削除される', () {
        final history = UserRequestHistory();
        
        // 古いリクエストを追加（テスト用に過去の時刻を設定）
        final oldTime = DateTime.now().subtract(const Duration(minutes: 2));
        history.requests.add(oldTime);
        history.addRequest(); // 現在時刻

        expect(history.getRequestCount(), equals(2));

        // 1分のウィンドウで古いリクエストを削除
        history.cleanOldRequests(const Duration(minutes: 1));
        expect(history.getRequestCount(), equals(1));
      });
    });

    group('checkRateLimit', () {
      test('設定されていないアクションは常に許可される', () async {
        final result = await rateLimiter.checkRateLimit('test-user', 'unknown-action');
        expect(result, isTrue);
      });

      test('初回リクエストは許可される', () async {
        final result = await rateLimiter.checkRateLimit('test-user', 'login');
        expect(result, isTrue);
      });

      test('ブロック状態の確認ができる', () {
        expect(rateLimiter.isUserBlocked('test-user'), isFalse);
      });

      test('ユーザーのブロック解除ができる', () {
        rateLimiter.unblockUser('test-user');
        expect(rateLimiter.isUserBlocked('test-user'), isFalse);
      });
    });

    group('統計情報', () {
      test('統計情報が正しく取得できる', () {
        final stats = rateLimiter.getStatistics();
        expect(stats, isA<Map<String, Map<String, dynamic>>>());
      });
    });

    group('クリーンアップ', () {
      test('クリーンアップが例外を投げない', () {
        expect(() => rateLimiter.cleanupOldData(), returnsNormally);
      });

      test('定期クリーンアップが開始できる', () {
        expect(() => rateLimiter.startPeriodicCleanup(), returnsNormally);
      });
    });
  });
} 