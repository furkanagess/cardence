import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import 'network_graph_state.dart';

class NetworkGraphCubit extends Cubit<NetworkGraphState> {
  NetworkGraphCubit({
    required GetNetworkGraph getNetworkGraph,
    required GetNetworkGraphPath getNetworkGraphPath,
  })  : _getNetworkGraph = getNetworkGraph,
        _getNetworkGraphPath = getNetworkGraphPath,
        super(const NetworkGraphState());

  final GetNetworkGraph _getNetworkGraph;
  final GetNetworkGraphPath _getNetworkGraphPath;

  Future<void> loadPersonal({
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return loadGraph(
      scope: GraphScope.personal,
      centerCardId: centerCardId,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
  }

  Future<void> loadEvent({
    required String eventGroupId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return loadGraph(
      scope: GraphScope.event,
      eventGroupId: eventGroupId,
      centerCardId: centerCardId,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
  }

  Future<void> loadGraph({
    required GraphScope scope,
    String? eventGroupId,
    String? organizationId,
    String? organizationEventId,
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: NetworkGraphStatus.loading,
        scope: scope,
        clearPath: true,
        clearError: true,
      ),
    );

    try {
      final graph = await _getNetworkGraph(
        scope: scope,
        eventGroupId: eventGroupId,
        organizationId: organizationId,
        organizationEventId: organizationEventId,
        centerCardId: centerCardId,
        maxDepth: maxDepth,
        maxNodes: maxNodes,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NetworkGraphStatus.loaded,
          graph: graph,
          clearError: true,
        ),
      );
    } on AuthApiException catch (e) {
      _emitFailure(e.message);
    } catch (_) {
      _emitFailure('Ağ grafiği alınamadı. Lütfen tekrar deneyin.');
    }
  }

  Future<void> findPath({
    required String fromCardId,
    required String toCardId,
    GraphScope scope = GraphScope.personal,
  }) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: NetworkGraphStatus.loading,
        scope: scope,
        clearPath: true,
        clearError: true,
      ),
    );

    try {
      final path = await _getNetworkGraphPath(
        fromCardId: fromCardId,
        toCardId: toCardId,
        scope: scope,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NetworkGraphStatus.loaded,
          path: path,
          clearError: true,
        ),
      );
    } on AuthApiException catch (e) {
      _emitFailure(e.message);
    } catch (_) {
      _emitFailure('Ağ yolu alınamadı. Lütfen tekrar deneyin.');
    }
  }

  void _emitFailure(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: NetworkGraphStatus.failure,
        errorMessage: message,
      ),
    );
  }
}
