import '../entities/graph_scope.dart';
import '../entities/network_graph_path.dart';
import '../repositories/network_graph_repository.dart';

class GetNetworkGraphPath {
  const GetNetworkGraphPath(this._repository);

  final NetworkGraphRepository _repository;

  Future<NetworkGraphPath> call({
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  }) {
    return _repository.getPath(
      fromCardId: fromCardId,
      toCardId: toCardId,
      scope: scope,
    );
  }
}
