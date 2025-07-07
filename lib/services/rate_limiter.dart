import 'dart:collection';
import 'security_logger.dart';

/// レート制限の設定
class RateLimitConfig {
  final int maxRequests;
  final Duration timeWindow;
  final Duration blockDuration;

  const RateLimitConfig({
    required this.maxRequests,
    required this.timeWindow,
    this.blockDuration = const Duration(minutes: 15),
  });
}

/// ユーザーのリクエスト履歴
class UserRequestHistory {
  final Queue<DateTime> requests = Queue<DateTime>();
  DateTime? blockedUntil;

  bool isBlocked() {
    if (blockedUntil == null) return false;
    
    if (DateTime.now().isAfter(blockedUntil!)) {
      blockedUntil = null;
      return false;
    }
    
    return true;
  }

  void block(Duration duration) {
    blockedUntil = DateTime.now().add(duration);
  }

  void addRequest() {
    requests.add(DateTime.now());
  }

  void cleanOldRequests(Duration timeWindow) {
    final cutoff = DateTime.now().subtract(timeWindow);
    while (requests.isNotEmpty && requests.first.isBefore(cutoff)) {
      requests.removeFirst();
    }
  }

  int getRequestCount() => requests.length;
}

/// レート制限を管理するサービス
class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  final Map<String, UserRequestHistory> _userHistories = {};
  final SecurityLogger _securityLogger = SecurityLogger();

  // 各アクションのレート制限設定
  static const Map<String, RateLimitConfig> _configs = {
    'login': RateLimitConfig(
      maxRequests: 5,
      timeWindow: Duration(minutes: 15),
      blockDuration: Duration(minutes: 30),
    ),
    'save_chat': RateLimitConfig(
      maxRequests: 50,
      timeWindow: Duration(minutes: 1),
      blockDuration: Duration(minutes: 5),
    ),
    'load_chats': RateLimitConfig(
      maxRequests: 100,
      timeWindow: Duration(minutes: 1),
      blockDuration: Duration(minutes: 2),
    ),
    'input_validation': RateLimitConfig(
      maxRequests: 200,
      timeWindow: Duration(minutes: 1),
      blockDuration: Duration(minutes: 1),
    ),
  };

  /// レート制限をチェックし、許可されるかどうかを返す
  Future<bool> checkRateLimit(String userId, String action) async {
    final config = _configs[action];
    if (config == null) {
      // 設定がない場合は許可
      return true;
    }

    final history = _getUserHistory(userId);

    // ブロック状態をチェック
    if (history.isBlocked()) {
      await _securityLogger.logRateLimitExceeded(userId, action);
      return false;
    }

    // 古いリクエストを削除
    history.cleanOldRequests(config.timeWindow);

    // 現在のリクエスト数をチェック
    if (history.getRequestCount() >= config.maxRequests) {
      // レート制限に達した場合、ユーザーをブロック
      history.block(config.blockDuration);
      await _securityLogger.logRateLimitExceeded(userId, action);
      await _securityLogger.logSuspiciousActivity(
        userId,
        'レート制限超過によりユーザーをブロックしました',
        metadata: {
          'action': action,
          'requestCount': history.getRequestCount(),
          'maxRequests': config.maxRequests,
          'timeWindow': config.timeWindow.inSeconds,
          'blockDuration': config.blockDuration.inSeconds,
        },
      );
      return false;
    }

    // リクエストを記録
    history.addRequest();
    return true;
  }

  /// ユーザーの履歴を取得（存在しない場合は作成）
  UserRequestHistory _getUserHistory(String userId) {
    return _userHistories.putIfAbsent(userId, () => UserRequestHistory());
  }

  /// ユーザーのブロック状態を確認
  bool isUserBlocked(String userId) {
    final history = _userHistories[userId];
    return history?.isBlocked() ?? false;
  }

  /// ユーザーのブロックを手動で解除（管理者用）
  void unblockUser(String userId) {
    final history = _userHistories[userId];
    if (history != null) {
      history.blockedUntil = null;
    }
  }

  /// 全ユーザーの統計情報を取得（デバッグ用）
  Map<String, Map<String, dynamic>> getStatistics() {
    final stats = <String, Map<String, dynamic>>{};
    
    for (final entry in _userHistories.entries) {
      final userId = entry.key;
      final history = entry.value;
      
      stats[userId] = {
        'isBlocked': history.isBlocked(),
        'blockedUntil': history.blockedUntil?.toIso8601String(),
        'recentRequestCount': history.getRequestCount(),
      };
    }
    
    return stats;
  }

  /// 古い履歴データをクリーンアップ
  void cleanupOldData() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    
    _userHistories.removeWhere((userId, history) {
      // ブロックされておらず、最近のリクエストもない場合は削除
      if (!history.isBlocked() && history.requests.isEmpty) {
        return true;
      }
      
      // 最後のリクエストが24時間以上前の場合は削除
      if (history.requests.isNotEmpty && 
          history.requests.last.isBefore(cutoff)) {
        return true;
      }
      
      return false;
    });
  }

  /// 定期的なクリーンアップを開始
  void startPeriodicCleanup() {
    // 1時間ごとにクリーンアップを実行
    Stream.periodic(const Duration(hours: 1)).listen((_) {
      cleanupOldData();
    });
  }
} 