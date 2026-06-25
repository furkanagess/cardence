import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/utils/find_network_graph_path.dart';
import 'network_graph_state.dart';

class NetworkGraphCubit extends Cubit<NetworkGraphState> {
  NetworkGraphCubit({
    required GetNetworkGraph getNetworkGraph,
  })  : _getNetworkGraph = getNetworkGraph,
        super(const NetworkGraphState());

  final GetNetworkGraph _getNetworkGraph;

  Future<void> loadInitial({
    GraphScope scope = GraphScope.personal,
    String? eventGroupId,
    String? centerCardId,
  }) {
    emit(
      state.copyWith(
        scope: scope,
        eventGroupId: eventGroupId,
        centerCardId: centerCardId,
        clearEventGroupId: scope != GraphScope.event,
      ),
    );

    if (scope == GraphScope.event && eventGroupId != null) {
      return loadEvent(
        eventGroupId: eventGroupId,
        centerCardId: centerCardId,
      );
    }

    return loadPersonal(centerCardId: centerCardId);
  }

  Future<void> loadPersonal({
    String? centerCardId,
    int maxDepth = 2,
    int maxNodes = 100,
  }) {
    return loadGraph(
      scope: GraphScope.personal,
      centerCardId: centerCardId ?? state.centerCardId,
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
      centerCardId: centerCardId ?? state.centerCardId,
      maxDepth: maxDepth,
      maxNodes: maxNodes,
    );
  }

  Future<void> reloadCurrent() {
    if (state.scope == GraphScope.event && state.eventGroupId != null) {
      return loadEvent(eventGroupId: state.eventGroupId!);
    }
    return loadPersonal();
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
        eventGroupId: eventGroupId,
        centerCardId: centerCardId ?? state.centerCardId,
        clearPath: true,
        clearPathSource: true,
        clearError: true,
        isPathLoading: false,
        clearEventGroupId: scope != GraphScope.event,
      ),
    );

    try {
      final graph = await _getNetworkGraph(
        scope: scope,
        eventGroupId: eventGroupId,
        organizationId: organizationId,
        organizationEventId: organizationEventId,
        centerCardId: centerCardId ?? state.centerCardId,
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

  void selectPersonalScope() {
    if (state.scope == GraphScope.personal) return;
    loadPersonal();
  }

  void selectEventScope(String eventGroupId) {
    if (state.scope == GraphScope.event && state.eventGroupId == eventGroupId) {
      return;
    }
    loadEvent(eventGroupId: eventGroupId);
  }

  void tapCardNode(GraphNode node) {
    if (node.type != GraphNodeType.card) return;
    final cardId = _cardIdFromNode(node);
    if (cardId == null) return;

    final sourceCardId = state.pathSourceCardId;
    if (sourceCardId == null) {
      emit(
        state.copyWith(
          pathSourceCardId: cardId,
          clearPath: true,
          isPathLoading: false,
        ),
      );
      return;
    }

    if (sourceCardId == cardId) {
      clearPathSelection();
      return;
    }

    findPathBetweenCards(fromCardId: sourceCardId, toCardId: cardId);
  }

  void findPathBetweenCards({
    required String fromCardId,
    required String toCardId,
  }) {
    final graph = state.graph;
    if (graph == null) return;

    emit(
      state.copyWith(
        isPathLoading: true,
        pathSourceCardId: fromCardId,
        clearPath: true,
        clearError: true,
      ),
    );

    final path = FindNetworkGraphPath.betweenCards(
      graph: graph,
      fromCardId: fromCardId,
      toCardId: toCardId,
    );

    if (isClosed) return;
    emit(
      state.copyWith(
        path: path,
        isPathLoading: false,
        pathSourceCardId: null,
      ),
    );
  }

  void clearPathSelection() {
    emit(
      state.copyWith(
        clearPath: true,
        clearPathSource: true,
        isPathLoading: false,
      ),
    );
  }

  String? pathSourceLabel() {
    final cardId = state.pathSourceCardId;
    final graph = state.graph;
    if (cardId == null || graph == null) return null;

    for (final node in graph.nodes) {
      if (node.cardId == cardId || node.id == 'card:$cardId') {
        return node.label;
      }
    }
    return cardId;
  }

  String? _cardIdFromNode(GraphNode node) {
    final cardId = node.cardId?.trim();
    if (cardId != null && cardId.isNotEmpty) return cardId;
    if (node.id.startsWith('card:')) {
      return node.id.substring(5);
    }
    return null;
  }

  void _emitFailure(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: NetworkGraphStatus.failure,
        errorMessage: message,
        isPathLoading: false,
      ),
    );
  }
}
