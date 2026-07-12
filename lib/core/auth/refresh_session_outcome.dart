/// RefreshAuthentication sonucu.
class RefreshSessionOutcome {
  const RefreshSessionOutcome._({
    required this.refreshed,
    required this.invalidRefreshToken,
  });

  const RefreshSessionOutcome.refreshed()
      : this._(refreshed: true, invalidRefreshToken: false);

  const RefreshSessionOutcome.failed()
      : this._(refreshed: false, invalidRefreshToken: false);

  const RefreshSessionOutcome.invalidToken()
      : this._(refreshed: false, invalidRefreshToken: true);

  final bool refreshed;
  final bool invalidRefreshToken;
}
