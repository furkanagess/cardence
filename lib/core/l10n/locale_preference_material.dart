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
