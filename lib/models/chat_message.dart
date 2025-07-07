/// メッセージの送信者を表現する列挙型
enum MessageSender {
  user,  // ユーザー
  ai,    // AI
}

/// チャットメッセージを表現するクラス
class ChatMessage {
  /// メッセージの本文
  final String text;
  
  /// メッセージの送信者
  final MessageSender sender;
  
  /// メッセージのタイムスタンプ
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  /// テスト用のファクトリコンストラクタ（タイムスタンプを現在時刻で設定）
  factory ChatMessage.now({
    required MessageSender sender,
    required String text,
  }) {
    return ChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  /// Firestoreとの連携用（後で実装）
  Map<String, dynamic> toJson() {
    return {
      'sender': sender.name,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Firestoreからの復元用（後で実装）
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
      ),
      text: json['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
} 