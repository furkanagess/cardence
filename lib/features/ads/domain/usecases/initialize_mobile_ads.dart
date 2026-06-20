import '../repositories/interstitial_ad_repository.dart';

class InitializeMobileAds {
  const InitializeMobileAds(this._repository);

  final InterstitialAdRepository _repository;

  Future<void> call() async {
    await _repository.initialize();
    await _repository.preload();
  }
}
