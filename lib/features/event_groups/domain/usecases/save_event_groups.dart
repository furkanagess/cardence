import '../entities/event_group.dart';
import '../repositories/event_group_repository.dart';

class SaveEventGroups {
  const SaveEventGroups(this._repository);
  final EventGroupRepository _repository;

  Future<void> call(List<EventGroup> groups) => _repository.saveEventGroups(groups);
}
