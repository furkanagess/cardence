import '../../../l10n/app_localizations.dart';

/// Onboarding adım etiketleri (ilerleme başlığı).
class OnboardingStepLabels {
  OnboardingStepLabels._();

  static List<String> all(AppLocalizations l10n) => [
        l10n.balang,
        l10n.kimlik,
        l10n.iBilgileri,
        l10n.letiim,
        l10n.ekBilgiler,
        l10n.nizleme,
      ];

  static String forIndex(AppLocalizations l10n, int index) {
    final labels = all(l10n);
    if (index < 0 || index >= labels.length) return '';
    return labels[index];
  }
}
