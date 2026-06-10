import '../entities/event_group.dart';
import '../repositories/event_group_repository.dart';

class CreateEventGroup {
  CreateEventGroup(this._repository);

  final EventGroupRepository _repository;

  Future<EventGroup> call(String name) => _repository.createEventGroup(name);
}
