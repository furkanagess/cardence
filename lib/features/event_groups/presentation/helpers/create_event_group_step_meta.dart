import '../../../../l10n/app_localizations.dart';

/// Etkinlik grubu oluşturma akışının adım sayısı ve başlık meta verisi.
class CreateEventGroupStepMeta {
  CreateEventGroupStepMeta._();

  static const int stepCount = 6;

  static String title(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.etkinlikAd,
      1 => l10n.konum,
      2 => l10n.etkinlikTarihi,
      3 => l10n.eventDescription,
      4 => l10n.etkinlikFotoraf,
      5 => l10n.selectCards,
      _ => l10n.yeniEtkinlikGrubu,
    };
  }

  static String subtitle(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.eventCreateNameSubtitle,
      1 => l10n.eventCreateLocationSubtitle,
      2 => l10n.eventCreateScheduleSubtitle,
      3 => l10n.eventCreateDetailsSubtitle,
      4 => l10n.eventCreatePhotoSubtitle,
      5 => l10n.eventGroupCardsStepSubtitle,
      _ => '',
    };
  }

  static bool showsOptionalBadge(int index) => index == 3 || index == 4;
}
