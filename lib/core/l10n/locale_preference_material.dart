import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/locale_preference.dart';

/// [LocalePreference] → MaterialApp locale.
Locale? materialLocaleFor(LocalePreference preference) {
  switch (preference) {
    case LocalePreference.turkish:
      return const Locale('tr');
    case LocalePreference.english:
      return const Locale('en');
    case LocalePreference.system:
      return null;
  }
}

/// Uygulama dilini RevenueCat paywall `preferredUILocale` formatına çevirir.
///
/// Paywall metinleri için tr / en zorunlu; diğer diller İngilizceye düşer.
String revenueCatPreferredLocaleFrom(Locale locale) {
  switch (locale.languageCode.toLowerCase()) {
    case 'tr':
      return 'tr-TR';
    case 'en':
      return 'en-US';
    default:
      return 'en-US';
  }
}

/// [LocalePreference] → RevenueCat preferred UI locale.
/// Sistem tercihi için `null` döner (cihaz dili kullanılır).
String? revenueCatPreferredLocaleForPreference(LocalePreference preference) {
  final material = materialLocaleFor(preference);
  if (material == null) return null;
  return revenueCatPreferredLocaleFrom(material);
}
