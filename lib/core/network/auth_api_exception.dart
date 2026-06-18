class AuthApiException implements Exception {
  AuthApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? errorCode;

  bool get isUnauthorized => statusCode == 401;

  /// Oturum yenilenemez; kullanıcı tekrar giriş yapmalı.
  bool get requiresReLogin =>
      isUnauthorized ||
      message.contains('Oturum süresi doldu') ||
      message.contains('Oturum bulunamadı');

  @override
  String toString() => message;
}
