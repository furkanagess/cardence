import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../config/store_config.dart';
import '../constants/app_constants.dart';

/// Uygulama mağaza bağlantısını arkadaşlarla paylaşma.
class AppShare {
  AppShare._();

  static String storeListingUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosUri = StoreConfig.appStoreListingUri();
      if (iosUri != null) return iosUri.toString();
    }
    return StoreConfig.playStoreListingUri().toString();
  }

  static String message() {
    return '${AppConstants.appName} ile dijital kartvizitini oluştur, '
        'networking\'de topladığın kartları tek yerde sakla.\n\n'
        'İndir: ${storeListingUrl()}';
  }

  static Future<void> share({Rect? sharePositionOrigin}) {
    return Share.share(
      message(),
      subject: '${AppConstants.appName} – ${AppConstants.appTagline}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
