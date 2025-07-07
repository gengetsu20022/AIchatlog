/// アプリケーションで使用するユーザー情報
class AppUser {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  /// FirebaseユーザーからAppUserを作成（テスト用の仮実装）
  factory AppUser.fromFirebase(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser?.uid ?? 'test_uid',
      email: firebaseUser?.email ?? 'test@example.com',
      displayName: firebaseUser?.displayName ?? 'Test User',
    );
  }

  /// テスト用のダミーユーザー
  factory AppUser.testUser() {
    return const AppUser(
      uid: 'test_uid',
      email: 'test@example.com',
      displayName: 'Test User',
    );
  }
} 