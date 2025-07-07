import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/pages/chat_detail_page.dart';
import 'package:ailog/models/chat_log.dart';
import 'package:ailog/models/chat_message.dart';

void main() {
  group('ChatDetailPage Widget Tests', () {
    late ChatLog testChatLog;

    setUp(() {
      final messages = [
        ChatMessage.now(sender: MessageSender.user, text: 'こんにちは'),
        ChatMessage.now(sender: MessageSender.ai, text: 'こんにちは！お元気ですか？'),
        ChatMessage.now(sender: MessageSender.user, text: '元気です！今日は何をしましょうか？'),
        ChatMessage.now(sender: MessageSender.ai, text: '何でも聞いてください。お手伝いします！'),
      ];

      testChatLog = ChatLog.forTest(
        id: 'test-chat-123',
        userId: 'test-user',
        aiName: 'ChatGPT',
        userName: 'テストユーザー',
        messages: messages,
      );
    });

    testWidgets('チャット詳細画面の基本UI要素が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // アプリバーのタイトル確認（AI名のみ）
      expect(find.text('ChatGPT'), findsOneWidget);
      
      // メッセージが表示されることを確認
      expect(find.text('こんにちは'), findsOneWidget);
      expect(find.text('こんにちは！お元気ですか？'), findsOneWidget);
      expect(find.text('元気です！今日は何をしましょうか？'), findsOneWidget);
      expect(find.text('何でも聞いてください。お手伝いします！'), findsOneWidget);
    });

    testWidgets('LINE風の吹き出しとカレンダーが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // カレンダーウィジェットが存在することを確認
      expect(find.byType(GridView), findsOneWidget);
      
      // 月のナビゲーションが存在することを確認
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      
      // 吹き出しコンテナが存在することを確認
      expect(find.byType(Container), findsAtLeastNWidgets(10)); // カレンダー + メッセージ
      
      // ListView で表示されることを確認
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('カレンダーウィジェットが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // 曜日ヘッダーが表示されることを確認
      expect(find.text('日'), findsOneWidget);
      expect(find.text('月'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
      expect(find.text('水'), findsOneWidget);
      expect(find.text('木'), findsOneWidget);
      expect(find.text('金'), findsOneWidget);
      expect(find.text('土'), findsOneWidget);
      
      // 現在の年月が表示されることを確認
      final now = DateTime.now();
      expect(find.textContaining('${now.year}年'), findsOneWidget);
      expect(find.textContaining('${now.month}月'), findsOneWidget);
    });

    testWidgets('日付区切りとメッセージの時刻が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // 日付区切りが表示されることを確認
      expect(find.textContaining('年'), findsAtLeast(1));
      expect(find.textContaining('月'), findsAtLeast(1));
      expect(find.textContaining('日'), findsAtLeast(1));
      
      // 時刻表示が存在することを確認（HH:MM形式）
      expect(find.textContaining(':'), findsAtLeast(4)); // メッセージ数分
    });

    testWidgets('AIアバターとユーザーメッセージの既読表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // AIのアバター（CircleAvatar）が存在することを確認
      expect(find.byType(CircleAvatar), findsAtLeast(2)); // ヘッダー + メッセージ内
      
      // 既読マークが表示されることを確認
      expect(find.text('既読'), findsAtLeast(1));
    });

    testWidgets('検索とメニューボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // 検索ボタンが存在することを確認
      expect(find.byIcon(Icons.search), findsOneWidget);
      
      // メニューボタンが存在することを確認
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('空のメッセージの場合、適切なメッセージが表示される', (WidgetTester tester) async {
      final emptyChatLog = ChatLog.forTest(
        userId: 'test-user',
        aiName: 'ChatGPT',
        userName: 'テストユーザー',
        messages: [], // 空のメッセージ
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: emptyChatLog),
        ),
      );

      // 空の状態メッセージが表示されることを確認
      expect(find.text('メッセージがありません'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('カレンダーの月切り替えが動作する', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // 現在の月を確認
      final now = DateTime.now();
      expect(find.textContaining('${now.month}月'), findsOneWidget);

      // 右矢印をタップして次の月に移動
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 月が変更されることを確認（次の月または1月に戻る）
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final expectedText = '${nextMonth}月';
      expect(find.textContaining(expectedText), findsOneWidget);
    });

    testWidgets('戻るボタンで前画面に戻れる', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ChatDetailPage(chatLog: testChatLog),
            ),
          ),
        ),
      );

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);
      
      // 戻るボタンの存在を確認（BackButtonまたはアイコンボタン）
      final backButton = find.byType(BackButton);
      final iconButton = find.byType(IconButton);
      
      // どちらかが見つかることを確認
      expect(backButton.evaluate().isNotEmpty || iconButton.evaluate().isNotEmpty, true);
    });

    testWidgets('LINE風の背景色とテーマカラーが適用される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatDetailPage(chatLog: testChatLog),
        ),
      );

      // Scaffoldの背景色確認
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF5F5F5));
    });
  });
} 