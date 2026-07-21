/// Google Sign-In (native SDK → backend idToken doğrulama).
///
/// [serverClientId]: Google Cloud Console → Web application OAuth client ID.
/// Backend `GoogleAuth:ClientId` ile aynı olmalıdır (idToken audience).
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '1011139931151-d5lsq79omrpdvojrs9o70ouj7ed3d244.apps.googleusercontent.com',
  );

  static const List<String> scopes = ['email', 'profile'];
}
