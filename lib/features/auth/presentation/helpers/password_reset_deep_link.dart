/// Mail veya deep link'ten gelen sifre sifirlama baglantisi parametreleri.
typedef PasswordResetLinkParams = ({String token, String? email});

PasswordResetLinkParams? parsePasswordResetLink(Uri uri) {
  if (uri.host != 'auth' || !uri.path.startsWith('/reset-password')) {
    return null;
  }

  final token = uri.queryParameters['token']?.trim();
  if (token == null || token.isEmpty) {
    return null;
  }

  final email = uri.queryParameters['email']?.trim();
  return (
    token: token,
    email: email != null && email.isNotEmpty ? email : null,
  );
}

bool isPasswordResetDeepLink(Uri uri) =>
    uri.scheme == 'com.furkanages.cardenceapp' &&
    parsePasswordResetLink(uri) != null;
