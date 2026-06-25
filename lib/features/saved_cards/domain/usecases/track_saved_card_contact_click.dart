import '../repositories/saved_card_repository.dart';

class TrackSavedCardContactClick {
  const TrackSavedCardContactClick(this._repository);

  final SavedCardRepository _repository;

  Future<void> call({
    required String cardId,
    required String contactType,
  }) {
    return _repository.trackPublicContactClick(
      cardId: cardId,
      contactType: contactType,
    );
  }
}
