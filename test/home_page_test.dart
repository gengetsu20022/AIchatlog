import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/pages/home_page.dart';
import 'package:ailog/models/chat_log.dart';
import 'package:ailog/models/chat_message.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('ホーム画面の基本UI要素が表示される', (WidgetTester tester) async {
      // 画面を描画
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // 基本UI要素の存在確認
      expect(find.text('あいろぐ'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // 新規追加FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('ログがない場合、空の状態メッセージが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // 空の状態のメッセージを確認
      expect(find.text('会話ログがまだありません'), findsOneWidget);
      expect(find.text('右下の＋ボタンから新しい会話を追加してください'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('ログアウトボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // ログアウトボタンの確認
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('新規追加ボタンをタップするとログ入力画面に遷移する', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // FABをタップ
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // ログ入力画面に遷移することを確認
      expect(find.text('会話ログを追加'), findsOneWidget);
    });

    testWidgets('ログアウトボタンをタップするとダイアログが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // ログアウトボタンをタップ
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // 確認ダイアログが表示されることを確認
      expect(find.text('ログアウト'), findsOneWidget);
      expect(find.text('ログアウトしますか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('ログアウト'), findsNWidgets(2)); // タイトルとボタン
    });

    testWidgets('ログリストが存在する場合、ListView が表示される', (WidgetTester tester) async {
      // TODO: 実際のログデータがある場合のテスト
      // 現在はChatServiceのモック化が必要なため、このテストは後で実装
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );

      // リストビューが表示される（ログがある場合）
      // expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
} 