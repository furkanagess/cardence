import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../data/datasources/post_add_card_ad_counter_local_datasource.dart';
import '../repositories/interstitial_ad_repository.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Kart ekleme sonrası: reklam gösterir; her 3 reklamda bir paywall açar.
class ShowPostAddCardMonetization {
  const ShowPostAddCardMonetization(
    this._adRepository,
    this._subscriptionRepository,
    this._counter,
    this._authLocal,
  );

  static const int adsBeforePaywall = 3;

  final InterstitialAdRepository _adRepository;
  final SubscriptionRepository _subscriptionRepository;
  final PostAddCardAdCounterLocalDataSource _counter;
  final AuthLocalDataSource _authLocal;

  Future<void> call({
    required Future<void> Function() showPaywall,
  }) async {
    if (await _subscriptionRepository.hasPremiumWalletEntitlement()) {
      return;
    }

    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId == null || userId.isEmpty) return;

    final adShown = await _adRepository.show();
    if (!adShown) return;

    final count = await _counter.increment(userId);
    if (count % adsBeforePaywall == 0) {
      await showPaywall();
    }
  }
}
