import '../../features/auth/domain/usecases/complete_onboarding_remote.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';

/// Yerel onboarding bayrağını yazar; ardından sunucuya bildirir.
class CompleteOnboardingFlow {
  const CompleteOnboardingFlow({
    required CompleteOnboarding local,
    required CompleteOnboardingRemote remote,
  })  : _local = local,
        _remote = remote;

  final CompleteOnboarding _local;
  final CompleteOnboardingRemote _remote;

  Future<void> call() async {
    await _local();
    try {
      await _remote();
    } catch (_) {}
  }
}
