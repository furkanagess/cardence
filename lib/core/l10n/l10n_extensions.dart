import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart' show lookupAppLocalizations;

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
