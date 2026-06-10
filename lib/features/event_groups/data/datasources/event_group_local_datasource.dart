import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../models/event_group_model.dart';

const String _legacyKeyEventGroups = 'event_groups';

String eventGroupsStorageKey(String userId) => 'event_groups_$userId';

abstract class EventGroupLocalDataSource {
  Future<List<EventGroupModel>> getEventGroups();
  Future<void> replaceAll(List<EventGroupModel> groups);
  Future<void> clearForUser(String userId);
  Future<void> clearLegacyKeys();
}

class EventGroupLocalDataSourceImpl implements EventGroupLocalDataSource {
  EventGroupLocalDataSourceImpl(this._prefs, this._authLocal);

  final SharedPreferences _prefs;
  final AuthLocalDataSource _authLocal;

  Future<String> _storageKey() async {
    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId == null || userId.isEmpty) {
      return '${_legacyKeyEventGroups}_guest';
    }
    return eventGroupsStorageKey(userId);
  }

  Future<void> _migrateLegacyIfNeeded(String key) async {
    if (key.endsWith('_guest')) return;
    final existing = _prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return;
    final legacy = _prefs.getString(_legacyKeyEventGroups);
    if (legacy == null || legacy.isEmpty) return;
    await _prefs.setString(key, legacy);
    await _prefs.remove(_legacyKeyEventGroups);
  }

  @override
  Future<List<EventGroupModel>> getEventGroups() async {
    final key = await _storageKey();
    await _migrateLegacyIfNeeded(key);
    final jsonStr = _prefs.getString(key);
    return EventGroupModel.listFromJsonString(jsonStr);
  }

  @override
  Future<void> replaceAll(List<EventGroupModel> groups) async {
    final key = await _storageKey();
    await _prefs.setString(key, EventGroupModel.listToJsonString(groups));
  }

  @override
  Future<void> clearForUser(String userId) async {
    await _prefs.remove(eventGroupsStorageKey(userId));
  }

  @override
  Future<void> clearLegacyKeys() async {
    await _prefs.remove(_legacyKeyEventGroups);
  }
}
