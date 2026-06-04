import '../entities/saved_card.dart';

abstract class SavedCardRepository {
  Future<List<SavedCard>> getSavedCards();
  Future<void> saveCard(SavedCard card);
}
