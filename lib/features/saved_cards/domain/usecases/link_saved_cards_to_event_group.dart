import '../entities/saved_card.dart';
import '../helpers/saved_card_event_group_link.dart';
import 'save_saved_card.dart';

/// Seçilen kayıtlı kartları bir etkinlik grubuna bağlar (kart-merkezli güncelleme).
class LinkSavedCardsToEventGroup {
  const LinkSavedCardsToEventGroup(this._saveSavedCard);

  final SaveSavedCard _saveSavedCard;

  Future<void> call({
    required String groupId,
    required List<SavedCard> allCards,
    required List<String> cardIdsToAdd,
  }) async {
    if (cardIdsToAdd.isEmpty) return;

    final byId = {for (final card in allCards) card.cardId: card};

    for (final cardId in cardIdsToAdd) {
      final card = byId[cardId];
      if (card == null) continue;
      final updated = SavedCardEventGroupLink.linkToGroup(card, groupId);
      if (updated.linkedEventGroupIds.length == card.linkedEventGroupIds.length) {
        continue;
      }
      await _saveSavedCard(updated);
    }
  }
}
