import 'package:flutter/material.dart';

/// 利用規約ページ
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '利用規約',
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
              title: '第1条（適用）',
              content: '''1. 本利用規約（以下「本規約」）は、「あいろぐ」（以下「本サービス」）の利用に関する条件を定めるものです。
2. ユーザーは、本サービスを利用することにより、本規約に同意したものとみなされます。
3. 本規約は、本サービスの利用に関して、ユーザーと運営者との間に適用されます。''',
            ),
            
            _SectionWidget(
              title: '第2条（定義）',
              content: '''本規約において、以下の用語は次の意味を有します：

1. 「ユーザー」：本サービスを利用する個人
2. 「コンテンツ」：ユーザーが本サービスに投稿・保存するAI会話ログ
3. 「運営者」：本サービスを運営する個人・団体
4. 「第三者」：ユーザーおよび運営者以外の個人・法人・団体''',
            ),
            
            _SectionWidget(
              title: '第3条（サービス内容）',
              content: '''1. 本サービスは、AIとの会話ログを記録・閲覧できるWebアプリケーションです。
2. 本サービスは無料で提供されます。
3. 本サービスの機能は予告なく変更・追加・削除される場合があります。
4. 本サービスは現状有姿で提供され、可用性を保証するものではありません。''',
            ),
            
            _SectionWidget(
              title: '第4条（利用登録）',
              content: '''1. 利用登録は、Googleアカウントを使用して行います。
2. 登録申請者が未成年者の場合、法定代理人の同意を得た上で利用してください。
3. 以下に該当する場合、利用登録を拒否する場合があります：
   • 反社会的勢力に属する場合
   • 過去に本規約違反により利用停止となった場合
   • その他、運営者が不適切と判断した場合''',
            ),
            
            _SectionWidget(
              title: '第5条（禁止事項）',
              content: '''ユーザーは、本サービスの利用にあたり、以下の行為を行ってはなりません：

1. 法令または公序良俗に違反する行為
2. 犯罪行為に関連する行為
3. 他者の著作権、商標権等の知的財産権を侵害する行為
4. 他者の名誉、信用、プライバシーを侵害する行為
5. 他者に不利益、損害、不快感を与える行為
6. 詐欺等の犯罪に関連する行為
7. わいせつ、暴力的、残虐な内容を含む情報を投稿する行為
8. 機密情報、個人情報、クレジットカード情報等を投稿する行為
9. コンピュータウイルス等有害なプログラムを送信する行為
10. 本サービスの運営を妨害する行為
11. 運営者の設備に過度な負荷をかける行為
12. その他、運営者が不適切と判断する行為''',
            ),
            
            _SectionWidget(
              title: '第6条（コンテンツの取扱い）',
              content: '''1. ユーザーは、投稿するコンテンツについて、自らが適法な権利を有することを保証します。
2. ユーザーが投稿したコンテンツの著作権は、ユーザーに帰属します。
3. 運営者は、サービス運営上必要な範囲でコンテンツを使用できるものとします。
4. 運営者は、違法または不適切なコンテンツを予告なく削除する場合があります。''',
            ),
            
            _SectionWidget(
              title: '第7条（プライバシー）',
              content: '''1. ユーザーの個人情報の取扱いについては、別途プライバシーポリシーに定めるところによります。
2. ユーザーは、機密情報を本サービスに投稿しないよう注意してください。
3. 運営者は、ユーザーが投稿した機密情報について責任を負いません。''',
            ),
            
            SizedBox(height: 32),
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