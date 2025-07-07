/// 認証操作の結果を表現するクラス
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.errorMessage,
  });

  /// 成功した認証結果を作成
  factory AuthResult.success() {
    return const AuthResult(isSuccess: true);
  }

  /// 失敗した認証結果を作成
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
} 