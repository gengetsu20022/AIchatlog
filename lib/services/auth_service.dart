import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_result.dart';
import '../models/app_user.dart';
import 'security_logger.dart';
import 'rate_limiter.dart';

/// 本番レベルの認証機能を提供するサービスクラス
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final SecurityLogger _securityLogger = SecurityLogger();
  final RateLimiter _rateLimiter = RateLimiter();

  /// 現在のログイン状態
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// 現在のユーザー情報
  AppUser? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '名前未設定',
      );
    }
    return null;
  }

  /// 認証状態の変更を監視するStream
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '名前未設定',
        );
      }
      return null;
    });
  }

  /// Googleアカウントでログイン
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Google Sign-In フロー開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // ユーザーがログインをキャンセル
        await _securityLogger.logLoginFailure('unknown', 'ユーザーがログインをキャンセル');
        return AuthResult.failure('ログインがキャンセルされました');
      }

      // レート制限チェック
      final canProceed = await _rateLimiter.checkRateLimit(googleUser.email, 'login');
      if (!canProceed) {
        await _securityLogger.logLoginFailure(googleUser.email, 'レート制限超過');
        return AuthResult.failure('ログイン試行回数が上限に達しました。しばらく待ってから再試行してください。');
      }

      // ログイン試行をログ
      await _securityLogger.logLoginAttempt(googleUser.email, email: googleUser.email);

      // Google認証情報を取得
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase認証クレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseでサインイン
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // 新規ユーザーの場合はFirestoreに基本情報を保存
        await _saveUserToFirestore(userCredential.user!);
        
        // ログイン成功をログ
        await _securityLogger.logLoginSuccess(userCredential.user!.uid, email: userCredential.user!.email);
        
        return AuthResult.success();
      } else {
        await _securityLogger.logLoginFailure(googleUser.email, '認証に失敗');
        return AuthResult.failure('認証に失敗しました');
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = '異なる認証方法で既に登録されているアカウントです';
          break;
        case 'invalid-credential':
          errorMessage = '認証情報が無効です';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google認証が有効化されていません';
          break;
        case 'user-disabled':
          errorMessage = 'このアカウントは無効化されています';
          break;
        case 'user-not-found':
          errorMessage = 'ユーザーが見つかりません';
          break;
        case 'wrong-password':
          errorMessage = 'パスワードが間違っています';
          break;
        case 'too-many-requests':
          errorMessage = 'リクエストが多すぎます。しばらく待ってから再試行してください';
          break;
        default:
          errorMessage = 'ログインに失敗しました: ${e.message}';
      }
      
      // ログイン失敗をログ
      await _securityLogger.logLoginFailure('unknown', errorMessage);
      return AuthResult.failure(errorMessage);
    } catch (e) {
      await _securityLogger.logLoginFailure('unknown', '予期しないエラー: $e');
      return AuthResult.failure('予期しないエラーが発生しました: $e');
    }
  }

  /// ログアウト
  Future<AuthResult> signOut() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid ?? 'unknown';
      
      // Firebaseからサインアウト
      await _firebaseAuth.signOut();
      
      // Googleからもサインアウト
      await _googleSignIn.signOut();
      
      // ログアウトをログ
      await _securityLogger.logLogout(userId);
      
      return AuthResult.success();
    } catch (e) {
      return AuthResult.failure('ログアウトに失敗しました: $e');
    }
  }

  /// アカウント削除
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('ログインが必要です');
      }

      // アカウント削除をログ
      await _securityLogger.logAccountDeletion(user.uid);
      
      // Firestoreからユーザーデータを削除
      await _deleteUserFromFirestore(user.uid);
      
      // Firebase Authenticationからアカウントを削除
      await user.delete();
      
      // Googleからもサインアウト
      await _googleSignIn.signOut();
      
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return AuthResult.failure('セキュリティのため、再ログインが必要です');
      }
      return AuthResult.failure('アカウント削除に失敗しました: ${e.message}');
    } catch (e) {
      return AuthResult.failure('予期しないエラーが発生しました: $e');
    }
  }

  /// 新規ユーザーをFirestoreに保存
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      // 既に存在する場合は更新しない
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignInAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 最終ログイン時刻のみ更新
        await userDoc.update({
          'lastSignInAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('ユーザー情報の保存に失敗: $e');
      // エラーでも認証は成功させる
    }
  }

  /// FirestoreからユーザーデータやChatログを削除
  Future<void> _deleteUserFromFirestore(String uid) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // ユーザーのチャットログを削除
      final chatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final chatDoc in chatsQuery.docs) {
        batch.delete(chatDoc.reference);
        
        // メッセージサブコレクションも削除
        final messagesQuery = await chatDoc.reference
            .collection('messages')
            .get();
        
        for (final messageDoc in messagesQuery.docs) {
          batch.delete(messageDoc.reference);
        }
      }
      
      // ユーザードキュメントを削除
      batch.delete(FirebaseFirestore.instance.collection('users').doc(uid));
      
      await batch.commit();
    } catch (e) {
      print('ユーザーデータの削除に失敗: $e');
      throw e; // アカウント削除は失敗させる
    }
  }
} 