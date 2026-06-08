import '../repositories/auth_repository.dart';

class CompleteOnboardingRemote {
  const CompleteOnboardingRemote(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.completeOnboardingOnServer();
}
