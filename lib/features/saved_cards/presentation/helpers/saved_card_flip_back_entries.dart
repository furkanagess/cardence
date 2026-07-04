import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_entries.dart';

typedef SavedCardFlipEntry = ({String label, String value});

/// Cüzdan kartının flip arka yüzü: yalnızca hakkımda (kart ID ayrı rozet).
List<SavedCardFlipEntry> savedCardFlipBackEntries(
  SavedCard card,
  AppLocalizations l10n,
) {
  final about = card.about?.trim() ?? '';
  return [(label: l10n.hakkmda, value: about)];
}

/// Hakkımda yoksa ve henüz kişisel not eklenmemişse arka yüzde "Not ekle" göster.
bool savedCardShouldOfferFlipBackNote(SavedCard card) {
  if (card.hasAboutContent) return false;
  final note = card.note?.trim();
  return note == null || note.isEmpty;
}
