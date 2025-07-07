import '../models/chat_message.dart';

/// チャット会話ログを解析・分割するサービスクラス
/// 様々なAIサービスの会話ログに対応する汎用パーサー
class ChatParser {
  /// チャットログを解析してChatMessageのリストに変換
  /// 
  /// [input]: 解析対象のテキスト（例: "User: Hello\nAI: Hi there!"）
  /// [userName]: ユーザー名（例: "User", "あなた", "Taro"）
  /// [aiName]: AI名（例: "ChatGPT", "Gemini", "MyAI"）
  List<ChatMessage> parse(String logText, String userName, String aiName) {
    if (logText.trim().isEmpty) {
      return [];
    }

    final List<ChatMessage> messages = [];
    final lines = logText.split('\n');

    // 正規表現パターンを動的に作成
    // 例: (あなた|MyAI):(.*)
    // グループ1: 送信者名, グループ2: メッセージ本文
    final userPattern = RegExp('^${RegExp.escape(userName)}:(.*)');
    final aiPattern = RegExp('^${RegExp.escape(aiName)}:(.*)');

    ChatMessage? currentMessage;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final userMatch = userPattern.firstMatch(line);
      final aiMatch = aiPattern.firstMatch(line);

      String? senderName;
      String? text;

      if (userMatch != null) {
        senderName = userName;
        text = userMatch.group(1)?.trim();
      } else if (aiMatch != null) {
        senderName = aiName;
        text = aiMatch.group(1)?.trim();
      }

      if (senderName != null && text != null) {
        // 新しい発言が始まったので、前の発言をリストに追加
        if (currentMessage != null) {
          messages.add(currentMessage);
        }
        
        currentMessage = ChatMessage(
          sender: senderName == userName ? MessageSender.user : MessageSender.ai,
          text: text,
          timestamp: DateTime.now(), // タイムスタンプはここで仮設定
        );
      } else {
        // 発言者名で始まらない行は、直前のメッセージの続きとみなす
        if (currentMessage != null) {
          currentMessage = ChatMessage(
            sender: currentMessage.sender,
            text: '${currentMessage.text}\n$line',
            timestamp: currentMessage.timestamp,
          );
        }
      }
    }

    // 最後のメッセージをリストに追加
    if (currentMessage != null) {
      messages.add(currentMessage);
    }

    return messages;
  }


} 