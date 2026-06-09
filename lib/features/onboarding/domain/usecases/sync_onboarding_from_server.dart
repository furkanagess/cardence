import '../repositories/onboarding_repository.dart';

/// Sunucudan gelen onboarding durumunu yerel depoya yansıtır.
class SyncOnboardingFromServer {
  const SyncOnboardingFromServer(this._repository);

  final OnboardingRepository _repository;

  Future<void> call({required bool completed}) async {
    if (completed) {
      await _repository.setOnboardingCompleted();
    } else {
      await _repository.clearOnboardingCompleted();
    }
  }
}
