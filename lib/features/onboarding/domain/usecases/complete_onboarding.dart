import '../repositories/onboarding_repository.dart';

/// Onboarding tamamlandı olarak işaretle.
class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<void> call() => _repository.setOnboardingCompleted();
}
