import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/services/security_logger.dart';

void main() {
  group('SecurityLogger Tests', () {
    late SecurityLogger securityLogger;

    setUp(() {
      securityLogger = SecurityLogger();
    });

    group('SecurityEvent', () {
      test('SecurityEventが正しく作成される', () {
        final event = SecurityEvent(
          userId: 'test-user',
          eventType: SecurityEventType.loginAttempt,
          description: 'テストログイン試行',
          metadata: {'test': 'data'},
        );

        expect(event.userId, equals('test-user'));
        expect(event.eventType, equals(SecurityEventType.loginAttempt));
        expect(event.description, equals('テストログイン試行'));
        expect(event.metadata['test'], equals('data'));
        expect(event.timestamp, isA<DateTime>());
      });

      test('toFirestore()が正しいマップを返す', () {
        final event = SecurityEvent(
          userId: 'test-user',
          eventType: SecurityEventType.loginSuccess,
          description: 'テストログイン成功',
        );

        final firestoreData = event.toFirestore();

        expect(firestoreData['userId'], equals('test-user'));
        expect(firestoreData['eventType'], equals('loginSuccess'));
        expect(firestoreData['description'], equals('テストログイン成功'));
        expect(firestoreData['timestamp'], isNotNull);
      });
    });

    group('SecurityEventType', () {
      test('すべてのイベントタイプが定義されている', () {
        final eventTypes = SecurityEventType.values;
        
        expect(eventTypes.contains(SecurityEventType.loginAttempt), isTrue);
        expect(eventTypes.contains(SecurityEventType.loginSuccess), isTrue);
        expect(eventTypes.contains(SecurityEventType.loginFailure), isTrue);
        expect(eventTypes.contains(SecurityEventType.logout), isTrue);
        expect(eventTypes.contains(SecurityEventType.suspiciousActivity), isTrue);
        expect(eventTypes.contains(SecurityEventType.inputValidationFailure), isTrue);
        expect(eventTypes.contains(SecurityEventType.unauthorizedAccess), isTrue);
        expect(eventTypes.contains(SecurityEventType.accountDeletion), isTrue);
        expect(eventTypes.contains(SecurityEventType.rateLimitExceeded), isTrue);
      });
    });

    group('便利メソッド', () {
      test('logLoginAttempt()が正しいイベントを作成する', () async {
        // このテストは実際のFirestoreに接続しないため、
        // メソッドの呼び出しが例外を投げないことを確認
        expect(
          () => securityLogger.logLoginAttempt('test-user', email: 'test@example.com'),
          returnsNormally,
        );
      });

      test('logSuspiciousActivity()が正しいイベントを作成する', () async {
        expect(
          () => securityLogger.logSuspiciousActivity(
            'test-user',
            'テスト不審活動',
            metadata: {'ip': '192.168.1.1'},
          ),
          returnsNormally,
        );
      });
    });
  });
} 