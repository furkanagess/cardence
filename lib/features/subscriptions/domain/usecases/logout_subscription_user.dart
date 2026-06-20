import '../repositories/subscription_repository.dart';

class LogoutSubscriptionUser {
  const LogoutSubscriptionUser(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call() => _repository.logoutUser();
}
