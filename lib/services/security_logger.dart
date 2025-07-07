import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/security_utils.dart';

/// セキュリティイベントのタイプ
enum SecurityEventType {
  loginAttempt,
  loginSuccess,
  loginFailure,
  logout,
  suspiciousActivity,
  inputValidationFailure,
  unauthorizedAccess,
  accountDeletion,
  rateLimitExceeded,
}

/// セキュリティイベントのデータ構造
class SecurityEvent {
  final String userId;
  final SecurityEventType eventType;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  SecurityEvent({
    required this.userId,
    required this.eventType,
    required this.description,
    this.metadata = const {},
    DateTime? timestamp,
    this.ipAddress,
    this.userAgent,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventType': eventType.name,
      'description': SecurityUtils.sanitizeForLogging(description),
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }
}

/// セキュリティログを管理するサービス
class SecurityLogger {
  static final SecurityLogger _instance = SecurityLogger._internal();
  factory SecurityLogger() => _instance;
  SecurityLogger._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<SecurityEvent> _pendingEvents = [];
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  /// セキュリティイベントをログに記録
  Future<void> logSecurityEvent(SecurityEvent event) async {
    try {
      // ローカルキューに追加（オフライン対応）
      _pendingEvents.add(event);

      // Firestoreに保存を試行
      await _saveToFirestore(event);
      
      // 成功したらキューから削除
      _pendingEvents.remove(event);
      
      // コンソールにも出力（開発時のデバッグ用）
      print('Security Event: ${event.eventType.name} - ${event.description}');
      
    } catch (e) {
      print('セキュリティログの保存に失敗: $e');
      // 失敗してもアプリケーションの動作は継続
      _scheduleRetry(event);
    }
  }

  /// Firestoreへの保存処理
  Future<void> _saveToFirestore(SecurityEvent event) async {
    await _firestore
        .collection('security_logs')
        .add(event.toFirestore());
  }

  /// 保存失敗時のリトライ処理
  void _scheduleRetry(SecurityEvent event) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      await Future.delayed(_retryDelay * attempt);
      
      try {
        await _saveToFirestore(event);
        _pendingEvents.remove(event);
        print('セキュリティログの再送信に成功: ${event.eventType.name}');
        return;
      } catch (e) {
        print('セキュリティログの再送信に失敗 (試行 $attempt/$_maxRetries): $e');
      }
    }
    
    // 最大試行回数に達した場合はキューから削除
    _pendingEvents.remove(event);
    print('セキュリティログの保存を諦めました: ${event.eventType.name}');
  }

  /// 保留中のイベントを再送信
  Future<void> retryPendingEvents() async {
    final eventsToRetry = List<SecurityEvent>.from(_pendingEvents);
    
    for (final event in eventsToRetry) {
      try {
        await _saveToFirestore(event);
        _pendingEvents.remove(event);
      } catch (e) {
        // 再送信に失敗した場合はそのまま保留
        print('保留イベントの再送信に失敗: ${event.eventType.name}');
      }
    }
  }

  // 便利メソッド群

  /// ログイン試行をログ
  Future<void> logLoginAttempt(String userId, {String? email}) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.loginAttempt,
      description: 'ユーザーがログインを試行しました',
      metadata: {'email': email},
    ));
  }

  /// ログイン成功をログ
  Future<void> logLoginSuccess(String userId, {String? email}) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.loginSuccess,
      description: 'ユーザーが正常にログインしました',
      metadata: {'email': email},
    ));
  }

  /// ログイン失敗をログ
  Future<void> logLoginFailure(String userId, String reason) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.loginFailure,
      description: 'ログインに失敗しました: $reason',
      metadata: {'failureReason': reason},
    ));
  }

  /// ログアウトをログ
  Future<void> logLogout(String userId) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.logout,
      description: 'ユーザーがログアウトしました',
    ));
  }

  /// 不審なアクティビティをログ
  Future<void> logSuspiciousActivity(String userId, String description, {Map<String, dynamic>? metadata}) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.suspiciousActivity,
      description: '不審なアクティビティを検出: $description',
      metadata: metadata ?? {},
    ));
  }

  /// 入力検証失敗をログ
  Future<void> logInputValidationFailure(String userId, String fieldName, String reason) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.inputValidationFailure,
      description: '入力検証に失敗: $fieldName - $reason',
      metadata: {'fieldName': fieldName, 'reason': reason},
    ));
  }

  /// 不正アクセス試行をログ
  Future<void> logUnauthorizedAccess(String userId, String resource) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.unauthorizedAccess,
      description: '不正なアクセス試行: $resource',
      metadata: {'resource': resource},
    ));
  }

  /// アカウント削除をログ
  Future<void> logAccountDeletion(String userId) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.accountDeletion,
      description: 'アカウントが削除されました',
    ));
  }

  /// レート制限超過をログ
  Future<void> logRateLimitExceeded(String userId, String action) async {
    await logSecurityEvent(SecurityEvent(
      userId: userId,
      eventType: SecurityEventType.rateLimitExceeded,
      description: 'レート制限を超過: $action',
      metadata: {'action': action},
    ));
  }
} 