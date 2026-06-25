import '../entities/graph_scope.dart';
import '../entities/network_graph.dart';
import '../entities/network_graph_path.dart';

abstract class NetworkGraphRepository {
  Future<NetworkGraph> getGraph({
    required GraphScope scope,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  });

  Future<NetworkGraphPath> getPath({
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  });
}
