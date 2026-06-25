import 'package:equatable/equatable.dart';

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
    return ids;
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
    bool? isPathLoading,
    String? errorMessage,
    bool clearPath = false,
    bool clearPathSource = false,
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
        isPathLoading,
        errorMessage,
      ];
}
