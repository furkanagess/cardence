import '../entities/saved_card.dart';
import '../repositories/saved_card_repository.dart';

class SaveSavedCard {
  const SaveSavedCard(this._repository);
  final SavedCardRepository _repository;

  Future<void> call(SavedCard card) => _repository.saveCard(card);
}
