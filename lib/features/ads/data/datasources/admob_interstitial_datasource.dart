import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/config/admob_config.dart';

class AdMobInterstitialDataSource {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  Future<void> initialize() => MobileAds.instance.initialize();

  Future<void> load() async {
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;
    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad
            ..fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                load();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                load();
              },
            );
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> show() async {
    final ad = _interstitialAd;
    if (ad == null) {
      await load();
      return;
    }

    _interstitialAd = null;
    await ad.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
