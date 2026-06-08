class RestoreSessionResult {
  const RestoreSessionResult({
    required this.isAuthenticated,
    this.onboardingCompleted,
  });

  final bool isAuthenticated;
  final bool? onboardingCompleted;
}
