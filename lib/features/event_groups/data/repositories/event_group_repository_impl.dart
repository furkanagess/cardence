import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/event_group.dart';
import '../../domain/repositories/event_group_repository.dart';
import '../datasources/event_group_local_datasource.dart';
import '../datasources/event_group_remote_datasource.dart';
import '../models/event_group_model.dart';

class EventGroupRepositoryImpl implements EventGroupRepository {
  EventGroupRepositoryImpl({
    required EventGroupLocalDataSource local,
    required EventGroupRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
  })  : _local = local,
        _remote = remote,
        _authLocal = authLocal;

  final EventGroupLocalDataSource _local;
  final EventGroupRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;

  Future<String?> _tryAccessToken() async {
    final session = await _authLocal.getSession();
    if (session == null || session.accessToken.isEmpty) return null;
    return session.accessToken;
  }

  Future<String> _requireAccessToken() async {
    final token = await _tryAccessToken();
    if (token == null) {
      throw AuthApiException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    return token;
  }

  Future<void> _cacheGroups(List<EventGroupModel> groups) async {
    await _local.replaceAll(groups);
  }

  @override
  Future<List<EventGroup>> getEventGroups() async {
    final token = await _tryAccessToken();
    if (token != null) {
      try {
        final remoteGroups = await _remote.getEventGroups(accessToken: token);
        await _cacheGroups(remoteGroups);
        return remoteGroups.map((model) => model.toEntity()).toList();
      } on AuthApiException {
        rethrow;
      } catch (_) {
        // Sunucu erişilemezse yerel önbelleğe düş.
      }
    }

    final localGroups = await _local.getEventGroups();
    return localGroups.map((model) => model.toEntity()).toList();
  }

  @override
  Future<EventGroup> createEventGroup(String name) async {
    final token = await _requireAccessToken();
    final created = await _remote.createEventGroup(
      name: name,
      accessToken: token,
    );
    final localGroups = await _local.getEventGroups();
    final updated = [...localGroups, created];
    await _cacheGroups(updated);
    return created.toEntity();
  }

  @override
  Future<void> deleteEventGroup(String groupId) async {
    final token = await _requireAccessToken();
    await _remote.deleteEventGroup(groupId: groupId, accessToken: token);
    final localGroups = await _local.getEventGroups();
    final updated = localGroups.where((group) => group.id != groupId).toList();
    await _cacheGroups(updated);
  }

  @override
  Future<void> linkCards({
    required String groupId,
    required List<String> cardIds,
  }) async {
    if (cardIds.isEmpty) return;
    final token = await _requireAccessToken();
    await _remote.linkCards(
      groupId: groupId,
      cardIds: cardIds,
      accessToken: token,
    );
  }

  @override
  Future<void> unlinkCard({
    required String groupId,
    required String cardId,
  }) async {
    final token = await _requireAccessToken();
    await _remote.unlinkCard(
      groupId: groupId,
      cardId: cardId,
      accessToken: token,
    );
  }
}
