import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/chat_log.dart';
import '../models/chat_message.dart';
import 'log_input_page.dart';
import 'login_page.dart';
import 'chat_detail_page.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  
  List<ChatLog> _chatLogs = [];
  bool _isLoading = true;
  String? _currentUserId;
  bool _isDemo = false;

  @override
  void initState() {
    super.initState();
    _loadChatLogs();
  }

  // デモデータを生成
  List<ChatLog> _generateDemoData() {
    return [
      ChatLog(
        id: 'demo-1',
        userId: 'demo-user',
        chatDate: DateTime.now().subtract(const Duration(days: 2)),
        aiName: 'Claude',
        userName: 'デモユーザー',
        messages: [
          ChatMessage(
            text: 'Flutterを学び始めたのですが、どこから始めるのがおすすめですか？',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
          ),
          ChatMessage(
            text: 'Flutter学習でしたら、まず公式ドキュメントの「Get Started」から始めることをおすすめします。基本的なウィジェットの使い方から始めて、徐々に複雑なアプリケーションを作っていくのが良いでしょう。',
            sender: MessageSender.ai,
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
          ),
          ChatMessage(
            text: 'ありがとうございます！DartとFlutterの関係についても教えてください。',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
          ),
          ChatMessage(
            text: 'DartはFlutterアプリケーションを書くためのプログラミング言語です。Googleが開発したもので、FlutterフレームワークはDart言語で書かれています。モバイル、Web、デスクトップアプリケーションを一つのコードベースで開発できるのが特徴です。',
            sender: MessageSender.ai,
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
          ),
        ],
      ),
      ChatLog(
        id: 'demo-2',
        userId: 'demo-user',
        chatDate: DateTime.now().subtract(const Duration(days: 5)),
        aiName: 'ChatGPT',
        userName: 'デモユーザー',
        messages: [
          ChatMessage(
            text: '効率的なプログラミング学習方法を教えてください。',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ChatMessage(
            text: '効率的な学習のためには以下のステップをおすすめします：\n\n1. 基礎文法をしっかり学ぶ\n2. 小さなプロジェクトを作る\n3. エラーを恐れずにコードを書く\n4. コードレビューやペアプログラミングを活用\n5. 継続的な学習を心がける\n\n毎日少しずつでも継続することが最も重要です。',
            sender: MessageSender.ai,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      ChatLog(
        id: 'demo-3',
        userId: 'demo-user',
        chatDate: DateTime.now().subtract(const Duration(hours: 3)),
        aiName: 'Gemini',
        userName: 'デモユーザー',
        messages: [
          ChatMessage(
            text: 'プログラミングでAIツールを効果的に使う方法はありますか？',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          ChatMessage(
            text: 'AIツールは以下のような場面で効果的に活用できます：\n\n• コードの自動補完\n• エラーデバッグの支援\n• コードレビュー\n• ドキュメント作成\n• 学習サポート\n\nただし、AIが生成したコードは必ず理解してから使用し、自分で考える力も大切にしてください。',
            sender: MessageSender.ai,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),
    ];
  }

  Future<void> _loadChatLogs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 現在認証されているユーザーのIDを取得
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.uid.isEmpty) {
        // 未認証の場合はデモデータを表示
        setState(() {
          _chatLogs = _generateDemoData();
          _isLoading = false;
          _isDemo = true;
        });
        return;
      }
      
      _currentUserId = currentUser.uid;
      final chatLogs = await _chatService.getChatLogs(_currentUserId!);
      
      if (mounted) {
        setState(() {
          _chatLogs = chatLogs;
          _isLoading = false;
          _isDemo = false;
        });
      }
    } catch (e) {
      print('チャットログ読み込みエラー: $e');
      if (mounted) {
        // エラー時もデモデータを表示
        setState(() {
          _chatLogs = _generateDemoData();
          _isLoading = false;
          _isDemo = true;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('ログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログアウトに失敗しました: $e')),
          );
        }
      }
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final currentUser = _authService.currentUser;
        return SafeArea(
          child: Wrap(
            children: [
              // ユーザー情報表示
              if (currentUser != null)
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(currentUser.displayName),
                  subtitle: Text(currentUser.email),
                ),
              const Divider(),
              
              // プライバシーポリシー
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('プライバシーポリシー'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              
              // 利用規約
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('利用規約'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServicePage(),
                    ),
                  );
                },
              ),
              
              const Divider(),
              
              // アカウント削除
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'アカウント削除',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog();
                },
              ),
              
              // ログアウト
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('ログアウト'),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'アカウント削除',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            '⚠️ 警告\n\n'
            'アカウントを削除すると、以下のデータが完全に削除されます：\n\n'
            '• すべての会話ログ\n'
            '• ユーザー情報\n'
            '• アカウント認証情報\n\n'
            'この操作は取り消すことができません。\n'
            '本当にアカウントを削除しますか？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        // ローディング表示
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('アカウントを削除中...'),
              ],
            ),
          ),
        );

        final result = await _authService.deleteAccount();
        
        if (mounted) {
          Navigator.of(context).pop(); // ローディングダイアログを閉じる
          
          if (result.isSuccess) {
            // 削除成功時はログイン画面に戻る
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('アカウントが削除されました'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('アカウント削除に失敗しました: ${result.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // ローディングダイアログを閉じる
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('予期しないエラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToLogInput() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LogInputPage(),
      ),
    );
    
    // ログ追加画面から戻ってきた場合はデータを再読み込み
    if (result == true) {
      _loadChatLogs();
    }
  }

  void _navigateToChatDetail(ChatLog chatLog) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chatLog: chatLog),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '会話ログがまだありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '右下の＋ボタンから新しい会話を追加してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatLogList() {
    return ListView.builder(
      key: const Key('chat-log-list'),
      padding: const EdgeInsets.all(16.0),
      itemCount: _chatLogs.length,
      itemBuilder: (context, index) {
        final chatLog = _chatLogs[index];
        return Card(
          key: Key('chat-log-card-${chatLog.id}'),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            key: Key('chat-log-tile-${chatLog.id}'),
            leading: CircleAvatar(
              key: Key('chat-log-avatar-${chatLog.id}'),
              child: Text(
                chatLog.aiName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${chatLog.userName} × ${chatLog.aiName}',
              key: Key('chat-log-title-${chatLog.id}'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chatLog.chatDate.year}/${chatLog.chatDate.month}/${chatLog.chatDate.day}',
                  key: Key('chat-log-date-${chatLog.id}'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  chatLog.messages.isNotEmpty 
                      ? chatLog.messages.first.text
                      : 'メッセージなし',
                  key: Key('chat-log-preview-${chatLog.id}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Text(
              '${chatLog.messages.length}件',
              key: Key('chat-log-count-${chatLog.id}'),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            onTap: () => _navigateToChatDetail(chatLog),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('あいろぐ', key: Key('app-title')),
            if (_isDemo) ...[
              const SizedBox(width: 8),
              Container(
                key: const Key('demo-badge'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'デモ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isDemo)
            TextButton.icon(
              key: const Key('login-button'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text('ログイン'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          IconButton(
            key: const Key('settings-button'),
            onPressed: _showSettingsMenu,
            icon: const Icon(Icons.settings),
            tooltip: '設定',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isDemo)
            Container(
              key: const Key('demo-info'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'これはデモ画面です。実際の機能を体験するにはログインしてください。',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(key: Key('loading-indicator')))
                : _chatLogs.isEmpty
                    ? _buildEmptyState()
                    : _buildChatLogList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-chat-button'),
        onPressed: _isDemo ? _showDemoMessage : _navigateToLogInput,
        tooltip: '新しい会話を追加',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDemoMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('デモモードでは新しい会話の追加はできません。ログインしてお試しください。'),
        action: SnackBarAction(
          label: 'ログイン',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
    );
  }
} 