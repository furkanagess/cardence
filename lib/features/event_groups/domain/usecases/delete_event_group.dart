import '../repositories/event_group_repository.dart';

class DeleteEventGroup {
  DeleteEventGroup(this._repository);

  final EventGroupRepository _repository;

  Future<void> call(String groupId) => _repository.deleteEventGroup(groupId);
}
