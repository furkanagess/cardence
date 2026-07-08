import 'package:equatable/equatable.dart';

import '../helpers/network_graph_display.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/entities/network_graph_path.dart';

enum NetworkGraphStatus { initial, loading, loaded, failure }

class NetworkGraphState extends Equatable {
  const NetworkGraphState({
    this.status = NetworkGraphStatus.initial,
    this.scope = GraphScope.personal,
    this.eventGroupId,
    this.centerCardId,
    this.graph,
    this.path,
    this.pathSourceCardId,
    this.selectedNodeId,
    this.isPathLoading = false,
    this.errorMessage,
  });

  final NetworkGraphStatus status;
  final GraphScope scope;
  final String? eventGroupId;
  final String? centerCardId;
  final NetworkGraph? graph;
  final NetworkGraphPath? path;
  final String? pathSourceCardId;
  final String? selectedNodeId;
  final bool isPathLoading;
  final String? errorMessage;

  bool get isLoading => status == NetworkGraphStatus.loading;

  Set<String> get highlightedNodeIds {
    final ids = <String>{};
    if (pathSourceCardId != null) {
      final sourceNodeId = _nodeIdForCard(pathSourceCardId!);
      if (sourceNodeId != null) ids.add(sourceNodeId);
    }
    ids.addAll(path?.pathNodeIds ?? const []);

    final graph = this.graph;
    final selectedNodeId = this.selectedNodeId;
    if (graph != null && selectedNodeId != null) {
      ids.add(selectedNodeId);
      ids.addAll(
        NetworkGraphDisplay.neighborIds(selectedNodeId, graph.edges),
      );
    }

    return ids;
  }

  Set<String> get focusNodeIds {
    final graph = this.graph;
    if (graph == null) return {};
    return NetworkGraphDisplay.focusNodeIds(
      selectedNodeId: selectedNodeId,
      nodes: NetworkGraphDisplay.visibleNodes(graph.nodes),
      edges: NetworkGraphDisplay.visibleEdges(
        nodes: NetworkGraphDisplay.visibleNodes(graph.nodes),
        edges: graph.edges,
      ),
    );
  }

  String? _nodeIdForCard(String cardId) {
    final graph = this.graph;
    if (graph == null) return null;
    for (final node in graph.nodes) {
      if (node.cardId == cardId || node.id == 'card:$cardId') {
        return node.id;
      }
    }
    return null;
  }

  NetworkGraphState copyWith({
    NetworkGraphStatus? status,
    GraphScope? scope,
    String? eventGroupId,
    String? centerCardId,
    NetworkGraph? graph,
    NetworkGraphPath? path,
    String? pathSourceCardId,
    String? selectedNodeId,
    bool? isPathLoading,
    String? errorMessage,
    bool clearPath = false,
    bool clearPathSource = false,
    bool clearSelectedNode = false,
    bool clearError = false,
    bool clearEventGroupId = false,
  }) {
    return NetworkGraphState(
      status: status ?? this.status,
      scope: scope ?? this.scope,
      eventGroupId:
          clearEventGroupId ? null : (eventGroupId ?? this.eventGroupId),
      centerCardId: centerCardId ?? this.centerCardId,
      graph: graph ?? this.graph,
      path: clearPath ? null : (path ?? this.path),
      pathSourceCardId:
          clearPathSource ? null : (pathSourceCardId ?? this.pathSourceCardId),
      selectedNodeId:
          clearSelectedNode ? null : (selectedNodeId ?? this.selectedNodeId),
      isPathLoading: isPathLoading ?? this.isPathLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        scope,
        eventGroupId,
        centerCardId,
        graph,
        path,
        pathSourceCardId,
        selectedNodeId,
        isPathLoading,
        errorMessage,
      ];
}
