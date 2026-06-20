import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Google AdMob kimlikleri.
class AdMobConfig {
  AdMobConfig._();

  static const iosAppId = 'ca-app-pub-3499593115543692~2845897015';
  static const iosInterstitialAdUnitId =
      'ca-app-pub-3499593115543692/8998986211';

  static const androidAppId = 'ca-app-pub-3499593115543692~3216442429';
  static const androidInterstitialAdUnitId =
      'ca-app-pub-3499593115543692/5542956938';

  static String get interstitialAdUnitId {
    if (kIsWeb) return androidInterstitialAdUnitId;
    if (Platform.isIOS) return iosInterstitialAdUnitId;
    return androidInterstitialAdUnitId;
  }
}
