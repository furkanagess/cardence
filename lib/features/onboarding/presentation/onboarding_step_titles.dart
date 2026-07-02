import '../../../l10n/app_localizations.dart';

/// Onboarding adım başlıkları.
class OnboardingStepTitles {
  OnboardingStepTitles._();

  static List<String> _titles(AppLocalizations l10n) => [
        l10n.adnz,
        l10n.iBilgileri,
        l10n.profilFotoraf,
        l10n.ekBilgiler,
        l10n.kartNizlemesi,
      ];

  static String forIndex(AppLocalizations l10n, int index) {
    final titles = _titles(l10n);
    if (index < 0 || index >= titles.length) return '';
    return titles[index];
  }

  static bool showsOptionalBadge(int index) => index == 2 || index == 3;
}
