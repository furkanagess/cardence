import 'dart:async';

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
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
        },
      ),
    );
  }

  /// Reklam gösterildi ve kapatıldıysa `true` döner.
  Future<bool> show() async {
    final ad = _interstitialAd;
    if (ad == null) {
      await load();
      return false;
    }

    _interstitialAd = null;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        if (!completer.isCompleted) completer.complete(true);
        unawaited(load());
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(load());
      },
    );

    try {
      await ad.show();
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
      unawaited(load());
      return false;
    }

    return completer.future;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
