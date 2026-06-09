import '../entities/business_card.dart';
import '../repositories/business_card_repository.dart';

class UpsertBusinessCard {
  const UpsertBusinessCard(this._repository);

  final BusinessCardRepository _repository;

  Future<BusinessCard> call(BusinessCard card) async {
    final cardId = card.cardId?.trim();
    if (cardId != null && cardId.isNotEmpty) {
      return _repository.upsertCard(card);
    }
    return _repository.saveCard(card);
  }
}
