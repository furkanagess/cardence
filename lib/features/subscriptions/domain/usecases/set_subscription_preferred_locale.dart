import '../repositories/subscription_repository.dart';

/// RevenueCat paywall dilini uygulama diline eşler.
class SetSubscriptionPreferredLocale {
  const SetSubscriptionPreferredLocale(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(String? locale) => _repository.setPreferredLocale(locale);
}
