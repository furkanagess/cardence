import '../entities/event_group.dart';
import '../entities/event_group_create_input.dart';
import '../repositories/event_group_repository.dart';

class CreateEventGroup {
  CreateEventGroup(this._repository);

  final EventGroupRepository _repository;

  Future<EventGroup> call(EventGroupCreateInput input) =>
      _repository.createEventGroup(input);
}
