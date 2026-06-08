import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_card_model.dart';

const String _keySavedCards = 'saved_cards';

abstract class SavedCardLocalDataSource {
  Future<List<SavedCardModel>> getSavedCards();
  Future<void> saveCard(SavedCardModel card);
  Future<void> deleteCard(String cardId);
  Future<void> replaceAll(List<SavedCardModel> cards);
}

class SavedCardLocalDataSourceImpl implements SavedCardLocalDataSource {
  SavedCardLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<List<SavedCardModel>> getSavedCards() async {
    final jsonStr = _prefs.getString(_keySavedCards);
    return SavedCardModel.listFromJsonString(jsonStr);
  }

  @override
  Future<void> saveCard(SavedCardModel card) async {
    final list = await getSavedCards();
    final index = list.indexWhere((c) => c.cardId == card.cardId);
    final updated = List<SavedCardModel>.from(list);
    if (index >= 0) {
      updated[index] = card;
    } else {
      updated.add(card);
    }
    await _prefs.setString(_keySavedCards, SavedCardModel.listToJsonString(updated));
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final list = await getSavedCards();
    final updated =
        list.where((card) => card.cardId != cardId).toList(growable: false);
    await replaceAll(updated);
  }

  @override
  Future<void> replaceAll(List<SavedCardModel> cards) async {
    await _prefs.setString(
      _keySavedCards,
      SavedCardModel.listToJsonString(cards),
    );
  }
}
