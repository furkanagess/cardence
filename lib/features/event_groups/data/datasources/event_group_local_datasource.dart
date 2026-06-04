import 'package:shared_preferences/shared_preferences.dart';

import '../models/event_group_model.dart';

const String _keyEventGroups = 'event_groups';

abstract class EventGroupLocalDataSource {
  Future<List<EventGroupModel>> getEventGroups();
  Future<void> saveEventGroups(List<EventGroupModel> groups);
}

class EventGroupLocalDataSourceImpl implements EventGroupLocalDataSource {
  EventGroupLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<List<EventGroupModel>> getEventGroups() async {
    final jsonStr = _prefs.getString(_keyEventGroups);
    return EventGroupModel.listFromJsonString(jsonStr);
  }

  @override
  Future<void> saveEventGroups(List<EventGroupModel> groups) async {
    await _prefs.setString(_keyEventGroups, EventGroupModel.listToJsonString(groups));
  }
}
