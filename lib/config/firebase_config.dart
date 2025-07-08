import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数ベースのFirebase設定クラス
/// 
/// セキュリティを強化するため、APIキーなどの機密情報を
/// 環境変数から読み込みます。
class FirebaseConfig {
  /// 環境変数を読み込み
  static Future<void> loadEnvironment() async {
    try {
      await dotenv.load(fileName: ".env");
      if (kDebugMode) {
        print('✅ Environment variables loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Warning: Could not load .env file: $e');
        print('💡 Make sure to create .env file based on env.example');
      }
    }
  }

  /// 現在のプラットフォーム用のFirebaseOptionsを取得
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseConfig has not been configured for linux - '
          'you can reconfigure this by updating the environment variables.',
        );
      default:
        throw UnsupportedError(
          'FirebaseConfig is not supported for this platform.',
        );
    }
  }

  /// Web用Firebase設定
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _getRequiredEnv('FIREBASE_API_KEY'),
    appId: _getRequiredEnv('FIREBASE_APP_ID'),
    messagingSenderId: _getRequiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getRequiredEnv('FIREBASE_PROJECT_ID'),
    authDomain: _getRequiredEnv('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _getRequiredEnv('FIREBASE_STORAGE_BUCKET'),
    measurementId: _getEnv('FIREBASE_MEASUREMENT_ID'),
  );

  /// Android用Firebase設定
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _getRequiredEnv('FIREBASE_API_KEY'),
    appId: _getRequiredEnv('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _getRequiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getRequiredEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _getRequiredEnv('FIREBASE_STORAGE_BUCKET'),
  );

  /// iOS用Firebase設定
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _getRequiredEnv('FIREBASE_API_KEY'),
    appId: _getRequiredEnv('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _getRequiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getRequiredEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _getRequiredEnv('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _getRequiredEnv('FIREBASE_IOS_BUNDLE_ID'),
  );

  /// macOS用Firebase設定
  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _getRequiredEnv('FIREBASE_API_KEY'),
    appId: _getRequiredEnv('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _getRequiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getRequiredEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _getRequiredEnv('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _getRequiredEnv('FIREBASE_IOS_BUNDLE_ID'),
  );

  /// Windows用Firebase設定
  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _getRequiredEnv('FIREBASE_API_KEY'),
    appId: _getRequiredEnv('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: _getRequiredEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getRequiredEnv('FIREBASE_PROJECT_ID'),
    authDomain: _getRequiredEnv('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _getRequiredEnv('FIREBASE_STORAGE_BUCKET'),
    measurementId: _getEnv('FIREBASE_MEASUREMENT_ID'),
  );

  /// 必須環境変数を取得（存在しない場合はエラー）
  static String _getRequiredEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception(
        '🚨 Required environment variable "$key" is not set. '
        'Please check your .env file and ensure all required variables are configured.'
      );
    }
    return value;
  }

  /// オプション環境変数を取得
  static String? _getEnv(String key) {
    return dotenv.env[key];
  }

  /// 環境変数の設定状況をチェック
  static bool get isConfigured {
    try {
      _getRequiredEnv('FIREBASE_API_KEY');
      _getRequiredEnv('FIREBASE_PROJECT_ID');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// デバッグ用：設定された環境変数の一覧を表示（機密情報は隠す）
  static void debugPrintConfig() {
    if (!kDebugMode) return;
    
    print('🔧 Firebase Configuration Status:');
    print('  Project ID: ${_maskValue(_getEnv('FIREBASE_PROJECT_ID'))}');
    print('  API Key: ${_maskValue(_getEnv('FIREBASE_API_KEY'))}');
    print('  Auth Domain: ${_getEnv('FIREBASE_AUTH_DOMAIN')}');
    print('  Storage Bucket: ${_getEnv('FIREBASE_STORAGE_BUCKET')}');
    print('  Environment: ${_getEnv('ENVIRONMENT') ?? 'development'}');
  }

  /// 機密情報をマスクして表示
  static String? _maskValue(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length <= 8) return '***';
    return '${value.substring(0, 4)}***${value.substring(value.length - 4)}';
  }
} 