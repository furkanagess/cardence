import '../entities/event_group.dart';
import '../repositories/event_group_repository.dart';

class GetEventGroups {
  const GetEventGroups(this._repository);
  final EventGroupRepository _repository;

  Future<List<EventGroup>> call() => _repository.getEventGroups();
}
