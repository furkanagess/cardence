import '../../domain/repositories/interstitial_ad_repository.dart';

/// Reklamlar devre dışıyken kullanılan boş implementasyon.
class NoOpInterstitialAdRepository implements InterstitialAdRepository {
  const NoOpInterstitialAdRepository();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> preload() async {}

  @override
  Future<bool> show() async => false;
}
