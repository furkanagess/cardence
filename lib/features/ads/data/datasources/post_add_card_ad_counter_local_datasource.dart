import 'package:shared_preferences/shared_preferences.dart';

/// Kart ekleme sonrası gösterilen reklam sayacı (kullanıcı başına).
class PostAddCardAdCounterLocalDataSource {
  PostAddCardAdCounterLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static String storageKeyForUser(String userId) =>
      'post_add_card_interstitial_count_$userId';

  int readCount(String userId) =>
      _prefs.getInt(storageKeyForUser(userId)) ?? 0;

  Future<int> increment(String userId) async {
    final next = readCount(userId) + 1;
    await _prefs.setInt(storageKeyForUser(userId), next);
    return next;
  }

  Future<void> clearForUser(String userId) async {
    await _prefs.remove(storageKeyForUser(userId));
  }
}
