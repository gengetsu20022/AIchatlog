import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_log.dart';
import '../services/chat_parser.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../utils/security_utils.dart';

class LogInputPage extends StatefulWidget {
  const LogInputPage({super.key});

  @override
  State<LogInputPage> createState() => _LogInputPageState();
}

class _LogInputPageState extends State<LogInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _aiNameController = TextEditingController();
  final _chatLogController = TextEditingController();
  final _authService = AuthService();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _userNameController.dispose();
    _aiNameController.dispose();
    _chatLogController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveLog() async {
    if (_formKey.currentState!.validate()) {
      // ローディング状態を表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // 1. セキュリティ検証
        final userNameValidation = SecurityUtils.validateUserInput(
          input: _userNameController.text,
          fieldName: 'ユーザー名',
          maxLength: 50,
          allowSpecialChars: false,
        );
        
        final aiNameValidation = SecurityUtils.validateUserInput(
          input: _aiNameController.text,
          fieldName: 'AI名',
          maxLength: 50,
          allowSpecialChars: false,
        );
        
        final chatLogValidation = SecurityUtils.validateUserInput(
          input: _chatLogController.text,
          fieldName: '会話ログ',
          maxLength: 50000, // 大きめの制限
        );

        // バリデーションエラーチェック
        if (!userNameValidation.isValid) {
          throw Exception(userNameValidation.errorMessage);
        }
        if (!aiNameValidation.isValid) {
          throw Exception(aiNameValidation.errorMessage);
        }
        if (!chatLogValidation.isValid) {
          throw Exception(chatLogValidation.errorMessage);
        }

        // 2. 入力値のサニタイズ
        final sanitizedUserName = SecurityUtils.sanitizeForDatabase(_userNameController.text);
        final sanitizedAiName = SecurityUtils.sanitizeForDatabase(_aiNameController.text);
        final sanitizedChatLog = SecurityUtils.limitTextLength(_chatLogController.text);

        // 3. ChatParserでテキストを分割
        final chatParser = ChatParser();
        final messages = chatParser.parse(
          sanitizedChatLog,
          sanitizedUserName,
          sanitizedAiName,
        );

        // 4. 認証状態を確認
        final currentUser = _authService.currentUser;
        if (currentUser == null || currentUser.uid.isEmpty) {
          throw Exception('ログイン状態が確認できませんでした。再度ログインしてください。');
        }
        
        // 5. ChatLogオブジェクトを作成
        final chatLog = ChatLog(
          userId: currentUser.uid,
          chatDate: _selectedDate,
          aiName: sanitizedAiName,
          userName: sanitizedUserName,
          messages: messages,
        );

        // 6. ChatServiceで保存
        final chatService = ChatService();
        final result = await chatService.saveChatLog(chatLog);

        // ローディングダイアログを閉じる
        if (mounted) Navigator.of(context).pop();

        if (result.isSuccess) {
          // 成功時の処理
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('会話ログが保存されました')),
            );
            Navigator.of(context).pop(true); // データ再読み込みの合図
          }
        } else {
          // 保存失敗時の処理
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存に失敗しました: ${result.errorMessage}')),
            );
          }
        }
      } catch (e) {
        // 予期しないエラー時の処理
        if (mounted) {
          Navigator.of(context).pop(); // ローディングダイアログを閉じる
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldNameを入力してください';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会話ログを追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付選択
              Row(
                children: [
                  const Text(
                    '会話した日',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // ユーザー名入力
              TextFormField(
                key: const Key('user_name_field'),
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'あなたの名前',
                  border: OutlineInputBorder(),
                  hintText: 'ユーザー、あなた、太郎 など',
                ),
                validator: (value) => _validateRequired(value, 'ユーザー名'),
              ),
              const SizedBox(height: 16),
              
              // AI名入力
              TextFormField(
                key: const Key('ai_name_field'),
                controller: _aiNameController,
                decoration: const InputDecoration(
                  labelText: 'AIの名前',
                  border: OutlineInputBorder(),
                  hintText: 'ChatGPT、Gemini、Claude など',
                ),
                validator: (value) => _validateRequired(value, 'AI名'),
              ),
              const SizedBox(height: 16),
              
              // 会話ログ入力
              Expanded(
                child: TextFormField(
                  key: const Key('chat_log_field'),
                  controller: _chatLogController,
                  decoration: const InputDecoration(
                    labelText: '会話ログ',
                    border: OutlineInputBorder(),
                    hintText: 'あなた: こんにちは\nChatGPT: こんにちは！お元気ですか？\n...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) => _validateRequired(value, '会話ログ'),
                ),
              ),
              const SizedBox(height: 16),
              
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 