import '../../domain/entities/saved_card.dart';
import '../../domain/repositories/saved_card_repository.dart';
import '../datasources/saved_card_local_datasource.dart';
import '../models/saved_card_model.dart';

class SavedCardRepositoryImpl implements SavedCardRepository {
  SavedCardRepositoryImpl(this._dataSource);
  final SavedCardLocalDataSource _dataSource;

  @override
  Future<List<SavedCard>> getSavedCards() async {
    final models = await _dataSource.getSavedCards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveCard(SavedCard card) async {
    await _dataSource.saveCard(SavedCardModel.fromEntity(card));
  }
}
