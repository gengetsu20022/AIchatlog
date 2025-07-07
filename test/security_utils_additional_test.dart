import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/utils/security_utils.dart';

void main() {
  group('SecurityUtils additional tests', () {
    group('isValidIpAddress', () {
      test('有効なIPv4アドレスはtrueを返す', () {
        expect(SecurityUtils.isValidIpAddress('192.168.0.1'), isTrue);
      });

      test('範囲外のIPv4アドレスはfalseを返す', () {
        expect(SecurityUtils.isValidIpAddress('256.0.0.1'), isFalse);
      });
    });

    group('isSuspiciousUserAgent', () {
      test('Googlebotは疑わしいと判定される', () {
        const ua = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)';
        expect(SecurityUtils.isSuspiciousUserAgent(ua), isTrue);
      });

      test('一般ブラウザは疑わしくないと判定される', () {
        const ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36';
        expect(SecurityUtils.isSuspiciousUserAgent(ua), isFalse);
      });
    });

    test('CSRFトークンは重複しない', () {
      final tokens = <String>{};
      for (var i = 0; i < 1000; i++) {
        tokens.add(SecurityUtils.generateCsrfToken());
      }
      expect(tokens.length, 1000);
    });
  });
} 