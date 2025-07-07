import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/utils/security_utils.dart';

void main() {
  group('SecurityUtils Tests', () {
    
    group('sanitizeInput', () {
      test('HTML特殊文字が正しくエスケープされる', () {
        final input = '<script>alert("XSS")</script>';
        final result = SecurityUtils.sanitizeInput(input);
        
        expect(result, '&lt;script&gt;alert(&quot;XSS&quot;)&lt;&#x2F;script&gt;');
        expect(result.contains('<'), isFalse);
        expect(result.contains('>'), isFalse);
        expect(result.contains('"'), isFalse);
      });

      test('アンパサンドが正しくエスケープされる', () {
        final input = 'A&B&C';
        final result = SecurityUtils.sanitizeInput(input);
        
        expect(result, 'A&amp;B&amp;C');
      });
    });

    group('sanitizeForDatabase', () {
      test('危険なNoSQLクエリパターンが除去される', () {
        final input = 'user; \$where: function() { return true }';
        final result = SecurityUtils.sanitizeForDatabase(input);
        
        expect(result.contains('\$where'), isFalse);
      });

      test('JavaScript実行コードが除去される', () {
        final input = 'javascript:alert(1)';
        final result = SecurityUtils.sanitizeForDatabase(input);
        
        expect(result.contains('javascript:'), isFalse);
      });

      test('スクリプトタグが除去される', () {
        final input = '<script>malicious code</script>';
        final result = SecurityUtils.sanitizeForDatabase(input);
        
        expect(result.contains('<script'), isFalse);
      });
    });

    group('limitTextLength', () {
      test('指定長以下のテキストはそのまま返される', () {
        final input = 'Hello World';
        final result = SecurityUtils.limitTextLength(input, maxLength: 20);
        
        expect(result, equals(input));
      });

      test('指定長を超えるテキストは切り詰められる', () {
        final input = '1234567890';
        final result = SecurityUtils.limitTextLength(input, maxLength: 5);
        
        expect(result, equals('12345'));
        expect(result.length, equals(5));
      });
    });

    group('isContentAppropriate', () {
      test('一般的なテキストは適切と判定される', () {
        final content = 'こんにちは、元気ですか？';
        final result = SecurityUtils.isContentAppropriate(content);
        
        expect(result, isTrue);
      });

      test('パスワード情報が含まれると不適切と判定される', () {
        final content = 'password: secret123';
        final result = SecurityUtils.isContentAppropriate(content);
        
        expect(result, isFalse);
      });

      test('APIキー情報が含まれると不適切と判定される', () {
        final content = 'api_key: abcd1234';
        final result = SecurityUtils.isContentAppropriate(content);
        
        expect(result, isFalse);
      });

      test('シークレット情報が含まれると不適切と判定される', () {
        final content = 'secret=mysecret';
        final result = SecurityUtils.isContentAppropriate(content);
        
        expect(result, isFalse);
      });
    });

    group('validateUserInput', () {
      test('正常な入力はバリデーションを通過する', () {
        final result = SecurityUtils.validateUserInput(
          input: 'テストユーザー',
          fieldName: 'ユーザー名',
          maxLength: 50,
        );
        
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('空文字はバリデーションエラーになる', () {
        final result = SecurityUtils.validateUserInput(
          input: '',
          fieldName: 'ユーザー名',
        );
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('ユーザー名を入力してください'));
      });

      test('最小長に満たない場合はエラーになる', () {
        final result = SecurityUtils.validateUserInput(
          input: 'A',
          fieldName: 'テスト',
          minLength: 3,
        );
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('3文字以上'));
      });

      test('最大長を超える場合はエラーになる', () {
        final result = SecurityUtils.validateUserInput(
          input: '1234567890',
          fieldName: 'テスト',
          maxLength: 5,
        );
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('5文字以下'));
      });

      test('特殊文字が許可されていない場合はエラーになる', () {
        final result = SecurityUtils.validateUserInput(
          input: 'test<script>',
          fieldName: 'テスト',
          allowSpecialChars: false,
        );
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('使用できない文字'));
      });

      test('機密情報が含まれる場合はエラーになる', () {
        final result = SecurityUtils.validateUserInput(
          input: 'password: secret123',
          fieldName: 'テスト',
        );
        
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('機密情報'));
      });
    });

    group('sanitizeForLogging', () {
      test('パスワード情報がマスクされる', () {
        final input = 'Logged in with password: secret123';
        final result = SecurityUtils.sanitizeForLogging(input);
        
        expect(result, contains('[MASKED]'));
        expect(result.contains('secret123'), isFalse);
      });

      test('APIキー情報がマスクされる', () {
        final input = 'Using api_key: abcd1234efgh';
        final result = SecurityUtils.sanitizeForLogging(input);
        
        expect(result, contains('[MASKED]'));
        expect(result.contains('abcd1234efgh'), isFalse);
      });

      test('一般的なログメッセージはそのまま残る', () {
        final input = 'User logged in successfully';
        final result = SecurityUtils.sanitizeForLogging(input);
        
        expect(result, equals(input));
      });
    });
  });

  group('ValidationResult', () {
    test('成功時のResultが正しく作成される', () {
      final result = ValidationResult.success();
      
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('失敗時のResultが正しく作成される', () {
      final errorMessage = 'テストエラー';
      final result = ValidationResult.failure(errorMessage);
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals(errorMessage));
    });
  });
} 