import '../entities/event_group.dart';
import '../entities/event_group_create_input.dart';

/// Etkinlik grupları – sunucu birincil, yerel önbellek yedek.
abstract class EventGroupRepository {
  Future<List<EventGroup>> getEventGroups();

  Future<EventGroup> createEventGroup(EventGroupCreateInput input);

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
