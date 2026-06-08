import '../repositories/saved_card_repository.dart';

class DeleteSavedCard {
  const DeleteSavedCard(this._repository);

  final SavedCardRepository _repository;

  Future<void> call(String cardId) => _repository.deleteCard(cardId);
}
