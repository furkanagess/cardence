import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/google_auth_config.dart';
import '../../../../core/network/auth_api_exception.dart';

/// Native Google Sign-In → idToken (backend `/LoginWithGoogle`).
Future<String?> requestGoogleIdToken() async {
  final serverClientId = GoogleAuthConfig.serverClientId.trim();
  // iOS: Info.plist GIDClientID / clientId. Android: package + SHA-1 ile
  // Google Cloud'daki Android OAuth client eşleşir; clientId geçilmez.
  final clientId =
      Platform.isIOS ? GoogleAuthConfig.iosClientId.trim() : '';

  final googleSignIn = GoogleSignIn(
    scopes: GoogleAuthConfig.scopes,
    clientId: clientId.isEmpty ? null : clientId,
    serverClientId: serverClientId.isEmpty ? null : serverClientId,
  );

  final account = await googleSignIn.signIn();
  if (account == null) {
    return null;
  }

  final auth = await account.authentication;
  final idToken = auth.idToken;
  if (idToken == null || idToken.isEmpty) {
    throw AuthApiException(
      'Google kimlik jetonu alınamadı. Web Client ID yapılandırmasını kontrol edin.',
    );
  }
  return idToken;
}
