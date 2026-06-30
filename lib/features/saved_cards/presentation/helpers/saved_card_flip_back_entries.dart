import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_entries.dart';

typedef SavedCardFlipEntry = ({String label, String value});

/// Cüzdan kartının flip arka yüzü: hakkımda/yetenekler + kullanıcıya özel not.
List<SavedCardFlipEntry> savedCardFlipBackEntries(
  SavedCard card,
  AppLocalizations l10n,
) {
  final items = <SavedCardFlipEntry>[];
  final about = card.about?.trim();
  if (about != null && about.isNotEmpty) {
    items.add((label: l10n.hakkmda, value: about));
  }

  final skills = card.skills?.trim();
  if (skills != null && skills.isNotEmpty) {
    items.add((label: l10n.yetenekler, value: skills));
  }

  final note = card.note?.trim();
  if (note != null && note.isNotEmpty) {
    items.add((label: l10n.notlar, value: note));
  }

  return items;
}

/// Hakkımda yoksa ve henüz kişisel not eklenmemişse arka yüzde "Not ekle" göster.
bool savedCardShouldOfferFlipBackNote(SavedCard card) {
  if (card.hasAboutContent) return false;
  final note = card.note?.trim();
  return note == null || note.isEmpty;
}
