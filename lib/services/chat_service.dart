import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_log.dart';
import '../models/chat_message.dart';
import '../utils/security_utils.dart';
import 'security_logger.dart';
import 'rate_limiter.dart';

/// チャットログ保存の結果を表現するクラス
class SaveChatLogResult {
  final bool isSuccess;
  final String? chatLogId;
  final String? errorMessage;

  const SaveChatLogResult._({
    required this.isSuccess,
    this.chatLogId,
    this.errorMessage,
  });

  /// 成功時のファクトリコンストラクタ
  factory SaveChatLogResult.success(String chatLogId) {
    return SaveChatLogResult._(
      isSuccess: true,
      chatLogId: chatLogId,
    );
  }

  /// 失敗時のファクトリコンストラクタ
  factory SaveChatLogResult.failure(String errorMessage) {
    return SaveChatLogResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// チャットログの保存・取得を担当するサービスクラス
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecurityLogger _securityLogger = SecurityLogger();
  final RateLimiter _rateLimiter = RateLimiter();

  /// チャットログを保存する
  Future<SaveChatLogResult> saveChatLog(ChatLog chatLog) async {
    try {
      // セキュリティバリデーション
      if (chatLog.userId.isEmpty || chatLog.userId == 'temp-user-id') {
        await _securityLogger.logUnauthorizedAccess('unknown', 'チャットログ保存');
        return SaveChatLogResult.failure('認証が必要です。ログインしてください。');
      }

      // レート制限チェック
      final canProceed = await _rateLimiter.checkRateLimit(chatLog.userId, 'save_chat');
      if (!canProceed) {
        return SaveChatLogResult.failure('保存頻度が上限に達しました。しばらく待ってから再試行してください。');
      }

      if (chatLog.messages.isEmpty) {
        return SaveChatLogResult.failure('メッセージが空です');
      }

      // 追加のセキュリティチェック
      if (chatLog.messages.length > 1000) {
        return SaveChatLogResult.failure('メッセージ数が上限を超えています');
      }

      // 各メッセージの内容をチェック
      for (final message in chatLog.messages) {
        if (!SecurityUtils.isContentAppropriate(message.text)) {
          await _securityLogger.logInputValidationFailure(
            chatLog.userId, 
            'メッセージ内容', 
            '不適切なコンテンツが検出されました'
          );
          return SaveChatLogResult.failure('不適切なコンテンツが検出されました');
        }
        
        if (message.text.length > 10000) {
          await _securityLogger.logInputValidationFailure(
            chatLog.userId, 
            'メッセージ長', 
            'メッセージが長すぎます (${message.text.length}文字)'
          );
          return SaveChatLogResult.failure('メッセージが長すぎます');
        }
      }

      // ユーザー名・AI名のセキュリティチェック
      if (!SecurityUtils.isContentAppropriate(chatLog.userName) ||
          !SecurityUtils.isContentAppropriate(chatLog.aiName)) {
        await _securityLogger.logInputValidationFailure(
          chatLog.userId, 
          'ユーザー名またはAI名', 
          '名前に不適切な内容が含まれています'
        );
        return SaveChatLogResult.failure('名前に不適切な内容が含まれています');
      }

      // 1. chatsコレクションにドキュメントを作成
      final chatDocRef = await _firestore.collection('chats').add(chatLog.toFirestore());
      
      // 2. messagesサブコレクションにメッセージを保存
      final batch = _firestore.batch();
      for (int i = 0; i < chatLog.messages.length; i++) {
        final messageRef = chatDocRef.collection('messages').doc();
        batch.set(messageRef, {
          ...chatLog.messages[i].toJson(),
          'order': i,
        });
      }
      await batch.commit();
      
      return SaveChatLogResult.success(chatDocRef.id);

    } catch (e) {
      return SaveChatLogResult.failure('保存に失敗しました: $e');
    }
  }

  /// ユーザーのチャットログ一覧を取得する
  Future<List<ChatLog>> getChatLogs(String userId) async {
    try {
      // レート制限チェック
      final canProceed = await _rateLimiter.checkRateLimit(userId, 'load_chats');
      if (!canProceed) {
        throw Exception('データ取得頻度が上限に達しました。しばらく待ってから再試行してください。');
      }

      final querySnapshot = await _firestore
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .orderBy('chatDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ChatLog.fromFirestore(doc.data(), doc.id))
          .toList();

    } catch (e) {
      print('チャットログ取得エラー: $e');
      // エラーは呼び出し元に伝播させる
      rethrow;
    }
  }

  /// チャットログIDからメッセージを含む完全なデータを取得する
  Future<ChatLog?> getChatLogWithMessages(String chatLogId) async {
    try {
      // 1. チャットログの基本情報を取得
      final chatDoc = await _firestore.collection('chats').doc(chatLogId).get();
      if (!chatDoc.exists) return null;
      
      // 2. メッセージサブコレクションを取得
      final messagesSnapshot = await chatDoc.reference
          .collection('messages')
          .orderBy('order')
          .get();
      
      final messages = messagesSnapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
      
      // 3. 完全なChatLogオブジェクトを作成
      final chatLog = ChatLog.fromFirestore(chatDoc.data()!, chatDoc.id);
      return chatLog.copyWith(messages: messages);

    } catch (e) {
      print('チャットログ詳細取得エラー: $e');
      // エラーは呼び出し元に伝播させる
      rethrow;
    }
  }
} 