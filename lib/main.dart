import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'pages/home_page.dart';
import 'services/rate_limiter.dart';
import 'services/security_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数を読み込み
  await FirebaseConfig.loadEnvironment();
  
  // Firebase初期化（環境変数ベース）
  try {
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );
    print('✅ Firebase初期化成功');
    
    // デバッグモードでは設定情報を表示
    FirebaseConfig.debugPrintConfig();
  } catch (e) {
    print('🚨 Firebase初期化エラー: $e');
    print('💡 .envファイルが正しく設定されているか確認してください');
    // デモモード用：Firebase初期化に失敗してもアプリを続行
    print('⚠️ デモモードで続行します');
  }

  // セキュリティサービスの初期化
  try {
    final rateLimiter = RateLimiter();
    rateLimiter.startPeriodicCleanup();
    
    final securityLogger = SecurityLogger();
    await securityLogger.retryPendingEvents();
    
    print('セキュリティサービス初期化完了');
  } catch (e) {
    print('セキュリティサービス初期化エラー: $e');
    // エラーでもアプリは続行
  }
  
  runApp(const AilogApp());
}

class AilogApp extends StatelessWidget {
  const AilogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あいろぐ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
