import '../entities/event_group.dart';
import '../repositories/event_group_repository.dart';

class InviteEventGroupCardsByCardId {
  const InviteEventGroupCardsByCardId(this._repository);

  final EventGroupRepository _repository;

  Future<EventGroup> call({
    required String groupId,
    required List<String> cardIds,
  }) =>
      _repository.inviteCardsByCardId(
        groupId: groupId,
        cardIds: cardIds,
      );
}
