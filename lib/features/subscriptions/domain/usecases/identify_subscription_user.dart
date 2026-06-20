import '../repositories/subscription_repository.dart';

class IdentifySubscriptionUser {
  const IdentifySubscriptionUser(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(String userId) => _repository.identifyUser(userId);
}
