import '../../domain/entities/event_group.dart';
import '../../domain/repositories/event_group_repository.dart';
import '../datasources/event_group_local_datasource.dart';
import '../models/event_group_model.dart';

class EventGroupRepositoryImpl implements EventGroupRepository {
  EventGroupRepositoryImpl(this._dataSource);
  final EventGroupLocalDataSource _dataSource;

  @override
  Future<List<EventGroup>> getEventGroups() async {
    final models = await _dataSource.getEventGroups();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveEventGroups(List<EventGroup> groups) async {
    final models = groups.map((e) => EventGroupModel.fromEntity(e)).toList();
    await _dataSource.saveEventGroups(models);
  }
}
