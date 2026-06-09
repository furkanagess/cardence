import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../models/saved_card_model.dart';

const String _legacyKeySavedCards = 'saved_cards';

String savedCardsStorageKey(String userId) => 'saved_cards_$userId';

abstract class SavedCardLocalDataSource {
  Future<List<SavedCardModel>> getSavedCards();
  Future<void> saveCard(SavedCardModel card);
  Future<void> deleteCard(String cardId);
  Future<void> replaceAll(List<SavedCardModel> cards);
  Future<void> clearForUser(String userId);
  Future<void> clearLegacyKeys();
}

class SavedCardLocalDataSourceImpl implements SavedCardLocalDataSource {
  SavedCardLocalDataSourceImpl(this._prefs, this._authLocal);

  final SharedPreferences _prefs;
  final AuthLocalDataSource _authLocal;

  Future<String> _storageKey() async {
    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId == null || userId.isEmpty) return '${_legacyKeySavedCards}_guest';
    return savedCardsStorageKey(userId);
  }

  Future<void> _migrateLegacyIfNeeded(String key) async {
    if (key.endsWith('_guest')) return;
    final existing = _prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return;
    final legacy = _prefs.getString(_legacyKeySavedCards);
    if (legacy == null || legacy.isEmpty) return;
    await _prefs.setString(key, legacy);
    await _prefs.remove(_legacyKeySavedCards);
  }

  @override
  Future<List<SavedCardModel>> getSavedCards() async {
    final key = await _storageKey();
    await _migrateLegacyIfNeeded(key);
    final jsonStr = _prefs.getString(key);
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
    await replaceAll(updated);
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
    final key = await _storageKey();
    await _prefs.setString(
      key,
      SavedCardModel.listToJsonString(cards),
    );
  }

  @override
  Future<void> clearForUser(String userId) async {
    await _prefs.remove(savedCardsStorageKey(userId));
  }

  @override
  Future<void> clearLegacyKeys() async {
    await _prefs.remove(_legacyKeySavedCards);
    await _prefs.remove('${_legacyKeySavedCards}_guest');
  }
}
