import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/services/chat_parser.dart';
import 'package:ailog/models/chat_message.dart';

void main() {
  group('ChatParser', () {
    // テスト対象のパーサーのインスタンスを作成
    final parser = ChatParser();

    // 仕様書通りの基本テストケース
    test('基本的な会話ログを正しくパースできること', () {
      const logText = 'あなた: おはよう\nMyAI: おはようございます\nあなた: 今日もよろしくね';
      const userName = 'あなた';
      const aiName = 'MyAI';

      final result = parser.parse(logText, userName, aiName);

      expect(result.length, 3);

      expect(result[0].sender, MessageSender.user);
      expect(result[0].text, 'おはよう');

      expect(result[1].sender, MessageSender.ai);
      expect(result[1].text, 'おはようございます');

      expect(result[2].sender, MessageSender.user);
      expect(result[2].text, '今日もよろしくね');
    });

    // 仕様書にある、より柔軟な名前でのテストケース
    test('異なるユーザー名とAI名でも正しくパースできること', () {
      const logText = 'Taro: やあ！\nChatBot-X: こんにちは、Taroさん。';
      const userName = 'Taro';
      const aiName = 'ChatBot-X';

      final result = parser.parse(logText, userName, aiName);

      expect(result.length, 2);
      expect(result[0].sender, MessageSender.user);
      expect(result[0].text, 'やあ！');
      expect(result[1].sender, MessageSender.ai);
      expect(result[1].text, 'こんにちは、Taroさん。');
    });

    // 空行が含まれている場合のテストケース
    test('空行は無視されること', () {
      const logText = 'User: こんにちは\n\nAI: どうも\n';
      const userName = 'User';
      const aiName = 'AI';

      final result = parser.parse(logText, userName, aiName);

      expect(result.length, 2);
      expect(result[0].text, 'こんにちは');
      expect(result[1].text, 'どうも');
    });

    // 発言の後にコロンがない、またはスペースが複数ある場合など、少しイレギュラーなケース
    test('区切り文字の後のスペースが変動しても正しくパースできること', () {
      const logText = 'User:こんにちは\nAI:  どうも';
      const userName = 'User';
      const aiName = 'AI';

      final result = parser.parse(logText, userName, aiName);
      
      expect(result.length, 2);
      expect(result[0].sender, MessageSender.user);
      expect(result[0].text, 'こんにちは');
      expect(result[1].sender, MessageSender.ai);
      expect(result[1].text, 'どうも');
    });

    // どちらか一方しか発言していない場合のテストケース
    test('片方の発言者しかいないログでも正しくパースできること', () {
      const logText = 'User: 一人ごとです';
      const userName = 'User';
      const aiName = 'AI';

      final result = parser.parse(logText, userName, aiName);
      
      expect(result.length, 1);
      expect(result[0].sender, MessageSender.user);
      expect(result[0].text, '一人ごとです');
    });

    // 入力が空文字列の場合のテストケース
    test('入力が空の場合、空のリストを返すこと', () {
      const logText = '';
      const userName = 'User';
      const aiName = 'AI';

      final result = parser.parse(logText, userName, aiName);
      
      expect(result, isEmpty);
    });
  });
} 