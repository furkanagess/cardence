import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/network/auth_api_exception.dart';

class AppleAuthCredentialResult {
  const AppleAuthCredentialResult({
    required this.identityToken,
    this.authorizationCode,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String? authorizationCode;
  final String? givenName;
  final String? familyName;
}

/// Native Sign in with Apple → identityToken (backend `/LoginWithApple`).
Future<AppleAuthCredentialResult?> requestAppleCredential() async {
  final available = await SignInWithApple.isAvailable();
  if (!available) {
    throw AuthApiException('Bu cihazda Apple ile giriş desteklenmiyor.');
  }

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw AuthApiException('Apple kimlik jetonu alınamadı.');
    }

    return AppleAuthCredentialResult(
      identityToken: identityToken,
      authorizationCode: credential.authorizationCode,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  } on SignInWithAppleAuthorizationException catch (e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      return null;
    }
    throw AuthApiException('Apple ile giriş başarısız.');
  }
}
