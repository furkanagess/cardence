import '../repositories/onboarding_repository.dart';

/// Onboarding daha önce tamamlandı mı?
class GetOnboardingCompleted {
  const GetOnboardingCompleted(this._repository);

  final OnboardingRepository _repository;

  Future<bool> call() => _repository.isOnboardingCompleted();
}
