import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/services/chat_parser.dart';
import 'package:ailog/models/chat_message.dart';

void main() {
  group('ChatParser multi-line message', () {
    test('複数行の発言が一つのメッセージとして結合される', () {
      const logText = 'User: Hello\nThis is same message line 2\nAI: Hi there\nThanks';
      const userName = 'User';
      const aiName = 'AI';

      final parser = ChatParser();
      final result = parser.parse(logText, userName, aiName);

      expect(result.length, 2);

      expect(result[0].sender, MessageSender.user);
      expect(result[0].text, 'Hello\nThis is same message line 2');

      expect(result[1].sender, MessageSender.ai);
      expect(result[1].text, 'Hi there\nThanks');
    });
  });
} 