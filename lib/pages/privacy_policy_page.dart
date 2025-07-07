import 'package:flutter/material.dart';

/// プライバシーポリシーページ
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プライバシーポリシー',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '最終更新日: 2024年12月30日',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            
            _SectionWidget(
              title: '1. はじめに',
              content: '''「あいろぐ」（以下「本サービス」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めております。本プライバシーポリシーは、本サービスにおける個人情報の取扱いについて説明します。''',
            ),
            
            _SectionWidget(
              title: '2. 収集する情報',
              content: '''本サービスでは、以下の情報を収集します：

• Googleアカウント情報（メールアドレス、名前、プロフィール画像）
• AIとの会話ログデータ
• サービス利用状況（アクセス日時、機能の使用状況）
• デバイス情報（ブラウザの種類、IPアドレス）''',
            ),
            
            _SectionWidget(
              title: '3. 情報の利用目的',
              content: '''収集した情報は以下の目的で利用します：

• サービスの提供・運営
• ユーザー認証・本人確認
• サービスの改善・新機能の開発
• 技術的な問題の解決
• 法令に基づく対応''',
            ),
            
            _SectionWidget(
              title: '4. 情報の共有',
              content: '''当サービスは、法令に基づく場合を除き、ユーザーの同意なく第三者に個人情報を提供することはありません。

ただし、以下の場合は例外となります：
• 法令に基づく開示要求がある場合
• ユーザーまたは第三者の生命・身体・財産を保護する必要がある場合
• サービスの技術的運営に必要な範囲でのクラウドサービス事業者への委託''',
            ),
            
            _SectionWidget(
              title: '5. データの保存期間',
              content: '''• アカウント情報：アカウント削除まで
• 会話ログデータ：ユーザーが削除するまで、またはアカウント削除時
• アクセスログ：最大6ヶ月間''',
            ),
            
            _SectionWidget(
              title: '6. セキュリティ',
              content: '''当サービスは、個人情報の不正アクセス、紛失、破壊、改ざん、漏洩を防ぐため、以下の対策を実施しています：

• Firebase Authenticationによる認証
• Firestore Security Rulesによるデータアクセス制御
• HTTPS通信の使用
• 入力値のサニタイゼーション
• 機密情報の自動検出・除外''',
            ),
            
            _SectionWidget(
              title: '7. ユーザーの権利',
              content: '''ユーザーは以下の権利を有します：

• 個人情報の確認・訂正・削除の要求
• アカウントの削除
• データのエクスポート（将来実装予定）

これらの権利を行使したい場合は、アプリ内の設定画面またはお問い合わせフォームからご連絡ください。''',
            ),
            
            _SectionWidget(
              title: '8. Cookie等の技術',
              content: '''本サービスでは、ユーザー体験の向上のため、以下の技術を使用する場合があります：

• Firebase Authentication Token
• ローカルストレージ
• セッション管理用Cookie

これらの技術により個人を特定することはありません。''',
            ),
            
            _SectionWidget(
              title: '9. 第三者サービス',
              content: '''本サービスでは以下の第三者サービスを利用しています：

• Google Firebase（認証・データベース）
• Google Sign-In（ログイン機能）

これらのサービスには、それぞれ独自のプライバシーポリシーが適用されます。''',
            ),
            
            _SectionWidget(
              title: '10. ポリシーの変更',
              content: '''本プライバシーポリシーは、法令の変更やサービスの改善に伴い変更される場合があります。重要な変更がある場合は、アプリ内での通知またはメールにてお知らせします。''',
            ),
            
            _SectionWidget(
              title: '11. お問い合わせ',
              content: '''本プライバシーポリシーに関するお問い合わせは、アプリ内のお問い合わせフォームまたは以下の方法でお受けします：

• アプリ内フィードバック機能
• GitHub Issues（技術的な質問）''',
            ),
            
            SizedBox(height: 32),
            Text(
              '本プライバシーポリシーは、日本の個人情報保護法に準拠して作成されています。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final String title;
  final String content;

  const _SectionWidget({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
} 