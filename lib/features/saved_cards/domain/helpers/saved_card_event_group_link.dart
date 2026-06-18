import '../entities/saved_card.dart';
import '../entities/saved_card_origin.dart';

/// Etkinlik grubu ↔ kayıtlı kart bağlantı yardımcıları.
class SavedCardEventGroupLink {
  SavedCardEventGroupLink._();

  static SavedCard linkToGroup(SavedCard card, String groupId) {
    if (card.linkedEventGroupIds.contains(groupId)) return card;
    return card.copyWith(
      linkedEventGroupIds: [...card.linkedEventGroupIds, groupId],
    );
  }

  static SavedCard unlinkFromGroup(SavedCard card, String groupId) {
    if (!card.linkedEventGroupIds.contains(groupId)) return card;
    return card.copyWith(
      linkedEventGroupIds: card.linkedEventGroupIds
          .where((id) => id != groupId)
          .toList(growable: false),
    );
  }

  static SavedCardOrigin originFromSourceType(String? sourceType) {
    if (sourceType == SavedCardOrigin.manual.name) {
      return SavedCardOrigin.manual;
    }
    return SavedCardOrigin.cardence;
  }

  static String sourceTypeFromOrigin(SavedCardOrigin origin) => origin.name;
}
