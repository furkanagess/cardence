import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../repositories/interstitial_ad_repository.dart';

class ShowInterstitialAd {
  const ShowInterstitialAd(
    this._adRepository,
    this._subscriptionRepository,
  );

  final InterstitialAdRepository _adRepository;
  final SubscriptionRepository _subscriptionRepository;

  Future<bool> call() async {
    if (await _subscriptionRepository.hasPremiumWalletEntitlement()) {
      return false;
    }

    return _adRepository.show();
  }
}
