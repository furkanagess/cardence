import '../entities/business_card.dart';
import '../repositories/business_card_repository.dart';

class GetBusinessCards {
  const GetBusinessCards(this._repository);

  final BusinessCardRepository _repository;

  Future<List<BusinessCard>> call() => _repository.getBusinessCards();
}
