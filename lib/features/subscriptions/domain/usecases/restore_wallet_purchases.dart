import '../../../saved_cards/domain/repositories/saved_card_repository.dart';
import '../repositories/subscription_repository.dart';

class RestoreWalletPurchases {
  const RestoreWalletPurchases(
    this._subscriptionRepository,
    this._savedCardRepository,
  );

  final SubscriptionRepository _subscriptionRepository;
  final SavedCardRepository _savedCardRepository;

  Future<bool> call() async {
    final restored = await _subscriptionRepository.restorePurchases();
    if (!restored) return false;

    await _savedCardRepository.syncWalletPremium();
    return true;
  }
}
