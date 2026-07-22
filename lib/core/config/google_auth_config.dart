/// Google Sign-In (native SDK → backend idToken doğrulama).
///
/// [iosClientId] / [androidClientId]: Google Cloud Console → iOS / Android OAuth clients.
/// [serverClientId]: Web application OAuth client ID (idToken audience).
/// Backend `GoogleAuth:ClientId` ile [serverClientId] aynı olmalıdır.
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '1011139931151-hddebtvhu5gglr57vivc78a3oo89p36b.apps.googleusercontent.com',
  );

  static const String androidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue:
        '1011139931151-297bbvmpqb50f7dpfs0u4b4qov1j5af3.apps.googleusercontent.com',
  );

  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '1011139931151-d5lsq79omrpdvojrs9o70ouj7ed3d244.apps.googleusercontent.com',
  );

  static const List<String> scopes = ['email', 'profile'];
}
