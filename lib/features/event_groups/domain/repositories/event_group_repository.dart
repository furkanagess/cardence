import '../entities/event_group.dart';

/// Etkinlik gruplarının yerel saklanması – Domain interface.
abstract class EventGroupRepository {
  Future<List<EventGroup>> getEventGroups();
  Future<void> saveEventGroups(List<EventGroup> groups);
}
