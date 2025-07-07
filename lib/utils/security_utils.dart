/// セキュリティ関連のユーティリティクラス
import 'dart:math';

class SecurityUtils {
  
  /// HTMLエスケープによるXSS対策
  static String sanitizeInput(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// SQLインジェクション対策（NoSQL向け）
  static String sanitizeForDatabase(String input) {
    // 危険な文字列パターンをチェック
    final dangerousPatterns = [
      r'\$where',
      r'\$regex',
      r'javascript:',
      r'<script',
      r'eval\(',
      r'document\.',
      r'window\.',
    ];

    String sanitized = input;
    for (final pattern in dangerousPatterns) {
      sanitized = sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }

    return sanitized.trim();
  }

  /// テキスト長制限（DoS攻撃対策）
  static String limitTextLength(String input, {int maxLength = 10000}) {
    if (input.length > maxLength) {
      return input.substring(0, maxLength);
    }
    return input;
  }

  /// 不適切なコンテンツの基本チェック
  static bool isContentAppropriate(String content) {
    // 基本的な不適切コンテンツパターン
    final inappropriatePatterns = [
      r'password\s*[:=]\s*\w+',
      r'api[_-]?key\s*[:=]\s*\w+',
      r'secret\s*[:=]\s*\w+',
      r'token\s*[:=]\s*\w+',
      r'<script[^>]*>.*?</script>',
      r'javascript\s*:',
      r'data\s*:\s*text/html',
      r'vbscript\s*:',
      r'on\w+\s*=',
      r'expression\s*\(',
      r'''@import\s+["']''',
      r'<iframe[^>]*>',
      r'<object[^>]*>',
      r'<embed[^>]*>',
    ];

    for (final pattern in inappropriatePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(content)) {
        return false;
      }
    }

    return true;
  }

  /// 安全な文字列検証
  static ValidationResult validateUserInput({
    required String input,
    required String fieldName,
    int minLength = 1,
    int maxLength = 1000,
    bool allowSpecialChars = true,
  }) {
    // 空文字チェック
    if (input.trim().isEmpty) {
      return ValidationResult.failure('${fieldName}を入力してください');
    }

    // 長さチェック
    if (input.length < minLength) {
      return ValidationResult.failure('${fieldName}は${minLength}文字以上入力してください');
    }

    if (input.length > maxLength) {
      return ValidationResult.failure('${fieldName}は${maxLength}文字以下で入力してください');
    }

    // 特殊文字チェック（必要に応じて）
    if (!allowSpecialChars) {
      final hasSpecialChars = RegExp(r'[<>"\x27]').hasMatch(input);
      if (hasSpecialChars) {
        return ValidationResult.failure('${fieldName}に使用できない文字が含まれています');
      }
    }

    // 不適切コンテンツチェック
    if (!isContentAppropriate(input)) {
      return ValidationResult.failure('${fieldName}に機密情報が含まれている可能性があります');
    }

    return ValidationResult.success();
  }

  /// 安全なログ出力（機密情報マスク）
  static String sanitizeForLogging(String message) {
    return message
        .replaceAll(RegExp(r'password\s*[:=]\s*\S+', caseSensitive: false), 'password: [MASKED]')
        .replaceAll(RegExp(r'api[_-]?key\s*[:=]\s*\S+', caseSensitive: false), 'api_key: [MASKED]')
        .replaceAll(RegExp(r'secret\s*[:=]\s*\S+', caseSensitive: false), 'secret: [MASKED]')
        .replaceAll(RegExp(r'token\s*[:=]\s*\S+', caseSensitive: false), 'token: [MASKED]')
        .replaceAll(RegExp(r'Bearer\s+\S+', caseSensitive: false), 'Bearer [MASKED]')
        .replaceAll(RegExp(r'Authorization:\s*\S+', caseSensitive: false), 'Authorization: [MASKED]')
        .replaceAll(RegExp(r'Cookie:\s*\S+', caseSensitive: false), 'Cookie: [MASKED]')
        .replaceAll(RegExp(r'X-API-Key:\s*\S+', caseSensitive: false), 'X-API-Key: [MASKED]');
  }

  /// IPアドレスの検証（基本的なフォーマットチェック）
  static bool isValidIpAddress(String ip) {
    // IPv4: 0.0.0.0 – 255.255.255.255
    final ipv4Pattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}\$');
    final ipv6Pattern = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\$');

    if (ipv4Pattern.hasMatch(ip)) {
      final parts = ip.split('.');
      for (final part in parts) {
        final value = int.parse(part);
        if (value < 0 || value > 255) {
          return false;
        }
      }
      return true;
    }

    // IPv6 正規表現マッチのみで許可 (詳細チェックは省略)
    return ipv6Pattern.hasMatch(ip);
  }

  /// ユーザーエージェントの検証（基本的なボット検出）
  static bool isSuspiciousUserAgent(String userAgent) {
    final suspiciousPatterns = [
      r'bot',
      r'crawler',
      r'spider',
      r'scraper',
      r'curl',
      r'wget',
      r'python',
      r'requests',
      r'http',
      r'scanner',
    ];

    final lowerUserAgent = userAgent.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerUserAgent.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  /// CSRFトークンの生成（簡易版）
  static String generateCsrfToken() {
    final random = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    // 32-bit ランダム値を36進文字列に変換
    final randomPart = random.nextInt(0xFFFFFFFF).toRadixString(36);
    return 'csrf_${timestamp}_$randomPart';
  }
}

/// バリデーション結果クラス
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.failure(String errorMessage) {
    return ValidationResult._(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
} 