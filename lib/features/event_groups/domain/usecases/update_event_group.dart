import '../entities/event_group.dart';
import '../entities/event_group_update_input.dart';
import '../repositories/event_group_repository.dart';

class UpdateEventGroup {
  const UpdateEventGroup(this._repository);

  final EventGroupRepository _repository;

  Future<EventGroup> call(EventGroupUpdateInput input) =>
      _repository.updateEventGroup(input);
}
