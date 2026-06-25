import '../entities/graph_scope.dart';
import '../entities/network_graph.dart';
import '../repositories/network_graph_repository.dart';

class GetNetworkGraph {
  const GetNetworkGraph(this._repository);

  final NetworkGraphRepository _repository;

  Future<NetworkGraph> call({
    GraphScope scope = GraphScope.personal,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return _repository.getGraph(
      scope: scope,
      eventGroupId: eventGroupId,
      organizationId: organizationId,
      organizationEventId: organizationEventId,
      centerCardId: centerCardId,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
  }
}
