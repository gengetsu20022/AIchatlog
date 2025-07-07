import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

/// ログイン画面
/// TDD: テストを通すための最小限の実装
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hasAgreed = false;

  Future<void> _handleGoogleLogin() async {
    if (!_hasAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プライバシーポリシーと利用規約に同意してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();
      if (result.isSuccess) {
        // ホーム画面への遷移
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログインに失敗しました: ${result.errorMessage}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  void _navigateToTermsOfService() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリロゴ・タイトル
              const Text(
                'あいろぐ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              
              // キャッチコピー
              const Text(
                'AIとの会話を、美しい思い出として',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // 同意チェックボックス
              Row(
                children: [
                  Checkbox(
                    value: _hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        _hasAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: ''),
                          TextSpan(
                            text: 'プライバシーポリシー',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _navigateToPrivacyPolicy,
                          ),
                          const TextSpan(text: 'と'),
                          TextSpan(
                            text: '利用規約',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _navigateToTermsOfService,
                          ),
                          const TextSpan(text: 'に同意します'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Googleログインボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_hasAgreed) ? null : _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasAgreed ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Googleでログイン',
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