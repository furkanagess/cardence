import '../entities/saved_card.dart';
import '../repositories/saved_card_repository.dart';

class GetSavedCards {
  const GetSavedCards(this._repository);
  final SavedCardRepository _repository;

  Future<List<SavedCard>> call() => _repository.getSavedCards();
}
