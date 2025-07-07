import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ailog/pages/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('ログイン画面に必要な要素が表示される', (WidgetTester tester) async {
      // TDD: このテストは最初は失敗する（LoginPageが未実装のため）
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // アプリのロゴまたはタイトルが表示される
      expect(find.text('あいろぐ'), findsOneWidget);
      
      // キャッチコピーが表示される
      expect(find.text('AIとの会話を、美しい思い出として'), findsOneWidget);
      
      // Googleログインボタンが表示される
      expect(find.widgetWithText(ElevatedButton, 'Googleでログイン'), findsOneWidget);
    });

    testWidgets('Googleログインボタンをタップできる', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Googleログインボタンを探す
      final loginButton = find.widgetWithText(ElevatedButton, 'Googleでログイン');
      expect(loginButton, findsOneWidget);

      // ボタンがタップ可能であることを確認
      await tester.tap(loginButton);
      await tester.pump();
      
      // タップ後の状態変化をテスト（後で実装）
    });
  });
} 