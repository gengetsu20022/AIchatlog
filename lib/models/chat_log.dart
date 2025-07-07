import 'chat_message.dart';

/// 一つの会話セッション全体を表現するクラス
/// Firestoreの "chats" コレクションに対応
class ChatLog {
  final String? id; // Firestore document ID (新規作成時はnull)
  final String userId; // ユーザーID
  final DateTime chatDate; // 会話した日付
  final String aiName; // AIの名前
  final String userName; // ユーザーの名前
  final List<ChatMessage> messages; // メッセージのリスト

  const ChatLog({
    this.id,
    required this.userId,
    required this.chatDate,
    required this.aiName,
    required this.userName,
    required this.messages,
  });

  /// テスト用のファクトリコンストラクタ
  factory ChatLog.forTest({
    String? id,
    required String userId,
    required String aiName,
    required String userName,
    List<ChatMessage>? messages,
  }) {
    return ChatLog(
      id: id,
      userId: userId,
      chatDate: DateTime.now(),
      aiName: aiName,
      userName: userName,
      messages: messages ?? [],
    );
  }

  /// Firestoreへの保存用（メッセージはサブコレクションなので含めない）
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'chatDate': chatDate,
      'aiName': aiName,
      'userName': userName,
      'createdAt': DateTime.now(),
      'messageCount': messages.length,
    };
  }

  /// Firestoreからの復元用
  factory ChatLog.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatLog(
      id: id,
      userId: data['userId'] as String,
      chatDate: (data['chatDate'] as DateTime),
      aiName: data['aiName'] as String,
      userName: data['userName'] as String,
      messages: [], // メッセージは別途読み込み
    );
  }

  /// メッセージを含めたコピーを作成
  ChatLog copyWith({
    String? id,
    String? userId,
    DateTime? chatDate,
    String? aiName,
    String? userName,
    List<ChatMessage>? messages,
  }) {
    return ChatLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chatDate: chatDate ?? this.chatDate,
      aiName: aiName ?? this.aiName,
      userName: userName ?? this.userName,
      messages: messages ?? this.messages,
    );
  }

  /// デバッグ用
  @override
  String toString() {
    return 'ChatLog(id: $id, userId: $userId, aiName: $aiName, userName: $userName, messageCount: ${messages.length})';
  }
} 