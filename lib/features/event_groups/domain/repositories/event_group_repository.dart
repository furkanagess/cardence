import '../entities/event_group.dart';

/// Etkinlik grupları – sunucu birincil, yerel önbellek yedek.
abstract class EventGroupRepository {
  Future<List<EventGroup>> getEventGroups();

  Future<EventGroup> createEventGroup(String name);

  Future<void> deleteEventGroup(String groupId);

  Future<void> linkCards({
    required String groupId,
    required List<String> cardIds,
  });

  Future<void> unlinkCard({
    required String groupId,
    required String cardId,
  });
}
