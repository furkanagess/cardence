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

  @override
  String toString() => message;
}
