class AuthApiException implements Exception {
  AuthApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.errorCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? errorCode;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;

  /// Oturum yenilenemez; kullanıcı tekrar giriş yapmalı.
  bool get requiresReLogin =>
      isUnauthorized ||
      message.contains('Oturum süresi doldu') ||
      message.contains('Oturum bulunamadı') ||
      message.contains('Session expired') ||
      message.contains('Session not found');

  @override
  String toString() => message;
}
