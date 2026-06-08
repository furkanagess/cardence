import '../entities/business_card.dart';
import '../repositories/business_card_repository.dart';

class SaveBusinessCard {
  const SaveBusinessCard(this._repository);

  final BusinessCardRepository _repository;

  Future<BusinessCard> call(BusinessCard card) => _repository.saveCard(card);
}
