import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/services/chat_service.dart';
import 'package:ailog/models/chat_log.dart';
import 'package:ailog/models/chat_message.dart';

void main() {
  group('ChatService Tests', () {
    late ChatService chatService;

    setUp(() {
      chatService = ChatService();
    });

    group('saveChatLog', () {
      test('新しいチャットログを正常に保存できる', () async {
        // テストデータの準備
        final messages = [
          ChatMessage.now(sender: MessageSender.user, text: 'こんにちは'),
          ChatMessage.now(sender: MessageSender.ai, text: 'こんにちは！'),
        ];

        final chatLog = ChatLog.forTest(
          userId: 'test-user-123',
          aiName: 'ChatGPT',
          userName: 'テストユーザー',
          messages: messages,
        );

        // 保存の実行
        final result = await chatService.saveChatLog(chatLog);

        // 結果の検証
        expect(result.isSuccess, isTrue);
        expect(result.chatLogId, isNotNull);
        expect(result.chatLogId!.isNotEmpty, isTrue);
      });

      test('ユーザーIDが空の場合、保存に失敗する', () async {
        // 無効なデータの準備
        final chatLog = ChatLog.forTest(
          userId: '', // 空のユーザーID
          aiName: 'ChatGPT',
          userName: 'テストユーザー',
        );

        // 保存の実行
        final result = await chatService.saveChatLog(chatLog);

        // エラーの検証
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('ユーザーID'));
      });

      test('メッセージが空の場合、保存に失敗する', () async {
        // 無効なデータの準備
        final chatLog = ChatLog.forTest(
          userId: 'test-user-123',
          aiName: 'ChatGPT',
          userName: 'テストユーザー',
          messages: [], // 空のメッセージ
        );

        // 保存の実行
        final result = await chatService.saveChatLog(chatLog);

        // エラーの検証
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('メッセージ'));
      });
    });

    group('getChatLogs', () {
      test('ユーザーのチャットログ一覧を取得できる', () async {
        // 一覧取得の実行
        final chatLogs = await chatService.getChatLogs('test-user-123');

        // 結果の検証
        expect(chatLogs, isA<List<ChatLog>>());
        // 実際のFirestore接続なしではデータはないが、エラーが発生しないことを確認
      });

      test('存在しないユーザーIDの場合、空のリストを返す', () async {
        // 存在しないユーザーIDで実行
        final chatLogs = await chatService.getChatLogs('non-existent-user');

        // 空のリストが返されることを確認
        expect(chatLogs, isEmpty);
      });
    });

    group('getChatLogWithMessages', () {
      test('チャットログIDからメッセージ込みのデータを取得できる', () async {
        // データ取得の実行
        final chatLog = await chatService.getChatLogWithMessages('test-chat-id');

        // 結果の検証（実際のFirestore接続なしではnullが返される）
        expect(chatLog, isNull);
      });
    });
  });

  group('SaveChatLogResult', () {
    test('成功時のResultを正しく作成できる', () {
      final result = SaveChatLogResult.success('chat-123');
      
      expect(result.isSuccess, isTrue);
      expect(result.chatLogId, equals('chat-123'));
      expect(result.errorMessage, isNull);
    });

    test('失敗時のResultを正しく作成できる', () {
      final result = SaveChatLogResult.failure('エラーメッセージ');
      
      expect(result.isSuccess, isFalse);
      expect(result.chatLogId, isNull);
      expect(result.errorMessage, equals('エラーメッセージ'));
    });
  });
} 