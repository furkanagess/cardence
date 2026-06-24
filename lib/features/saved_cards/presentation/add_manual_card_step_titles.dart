import '../../../l10n/app_localizations.dart';

/// Manuel kart ekleme adım başlıkları (AppBar).
class AddManualCardStepTitles {
  AddManualCardStepTitles._();

  static List<String> _titles(AppLocalizations l10n) => [
        l10n.adSoyad,
        l10n.iBilgileri,
        l10n.ekBilgiler,
        l10n.kartNizlemesi,
      ];

  static String forIndex(AppLocalizations l10n, int index) {
    final titles = _titles(l10n);
    if (index < 0 || index >= titles.length) return '';
    return titles[index];
  }

  static bool showsOptionalBadge(int index) => false;
}
