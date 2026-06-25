import '../../../../core/auth/auth_token_provider.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/entities/network_graph_path.dart';
import '../../domain/repositories/network_graph_repository.dart';
import '../datasources/network_graph_remote_datasource.dart';

class NetworkGraphRepositoryImpl implements NetworkGraphRepository {
  const NetworkGraphRepositoryImpl({
    required NetworkGraphRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _remote = remote,
        _authTokens = authTokens;

  final NetworkGraphRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  @override
  Future<NetworkGraph> getGraph({
    required GraphScope scope,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) async {
    final token = await _authTokens.requireAccessToken();
    final graph = await _remote.getGraph(
      accessToken: token,
      scope: scope,
      eventGroupId: eventGroupId,
      organizationId: organizationId,
      organizationEventId: organizationEventId,
      centerCardId: centerCardId,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
    return graph.toEntity();
  }

  @override
  Future<NetworkGraphPath> getPath({
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  }) async {
    final token = await _authTokens.requireAccessToken();
    final path = await _remote.getPath(
      accessToken: token,
      fromCardId: fromCardId,
      toCardId: toCardId,
      scope: scope,
    );
    return path.toEntity();
  }
}
