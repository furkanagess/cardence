import '../repositories/event_group_repository.dart';

class LinkEventGroupCards {
  LinkEventGroupCards(this._repository);

  final EventGroupRepository _repository;

  Future<void> call({
    required String groupId,
    required List<String> cardIds,
  }) =>
      _repository.linkCards(groupId: groupId, cardIds: cardIds);
}
