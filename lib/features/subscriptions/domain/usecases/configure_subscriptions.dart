import '../repositories/subscription_repository.dart';

class ConfigureSubscriptions {
  const ConfigureSubscriptions(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call() => _repository.configure();
}
