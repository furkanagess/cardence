import '../entities/event_group.dart';
import '../entities/event_group_create_input.dart';
import '../entities/event_group_invitation.dart';
import '../entities/event_group_update_input.dart';

/// Etkinlik grupları – sunucu birincil, yerel önbellek yedek.
abstract class EventGroupRepository {
  Future<List<EventGroup>> getEventGroups();

  Future<List<EventGroupInvitation>> getPendingInvitations();

  Future<void> acceptInvitation(String invitationId);

  Future<void> rejectInvitation(String invitationId);

  Future<EventGroup> createEventGroup(EventGroupCreateInput input);

  Future<EventGroup> updateEventGroup(EventGroupUpdateInput input);

  Future<EventGroup> inviteCardsByCardId({
    required String groupId,
    required List<String> cardIds,
  });

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
