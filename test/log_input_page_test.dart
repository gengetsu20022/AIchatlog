import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/pages/log_input_page.dart';

void main() {
  group('LogInputPage Widget Tests', () {
    testWidgets('ログ入力画面の基本UI要素が表示される', (WidgetTester tester) async {
      // 画面を描画
      await tester.pumpWidget(
        MaterialApp(
          home: LogInputPage(),
        ),
      );

      // 基本UI要素の存在確認
      expect(find.text('会話ログを追加'), findsOneWidget);
      expect(find.text('会話した日'), findsOneWidget);
      expect(find.text('あなたの名前'), findsOneWidget);
      expect(find.text('AIの名前'), findsOneWidget);
      expect(find.text('会話ログ'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
      
      // 入力フィールドの確認
      expect(find.byType(TextFormField), findsNWidgets(3)); // ユーザー名、AI名、会話ログ
      expect(find.byIcon(Icons.calendar_today), findsOneWidget); // 日付選択
      expect(find.byType(ElevatedButton), findsOneWidget); // 保存ボタン
    });

    testWidgets('日付選択ボタンをタップすると日付ピッカーが開く', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LogInputPage(),
        ),
      );

      // 日付選択ボタンをタップ
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // 日付ピッカーが表示されることを確認
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('必須フィールドが空の時、保存ボタンを押すとバリデーションエラーが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LogInputPage(),
        ),
      );

      // 保存ボタンをタップ（フィールドは空のまま）
      await tester.tap(find.text('保存'));
      await tester.pump();

      // バリデーションエラーが表示されることを確認
      expect(find.text('ユーザー名を入力してください'), findsOneWidget);
      expect(find.text('AI名を入力してください'), findsOneWidget);
      expect(find.text('会話ログを入力してください'), findsOneWidget);
    });

    testWidgets('全ての必須フィールドが入力されている時、保存ボタンが有効になる', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LogInputPage(),
        ),
      );

      // フィールドに値を入力
      await tester.enterText(find.byKey(Key('user_name_field')), 'テストユーザー');
      await tester.enterText(find.byKey(Key('ai_name_field')), 'ChatGPT');
      await tester.enterText(find.byKey(Key('chat_log_field')), 'テストユーザー: こんにちは\nChatGPT: こんにちは！');

      // 保存ボタンをタップ
      await tester.tap(find.text('保存'));
      await tester.pump();

      // エラーが表示されないことを確認
      expect(find.text('ユーザー名を入力してください'), findsNothing);
      expect(find.text('AI名を入力してください'), findsNothing);
      expect(find.text('会話ログを入力してください'), findsNothing);
    });
  });
} 