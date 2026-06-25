import 'package:equatable/equatable.dart';

import '../../domain/entities/graph_scope.dart';
import '../../domain/entities/network_graph.dart';
import '../../domain/entities/network_graph_path.dart';

enum NetworkGraphStatus { initial, loading, loaded, failure }

class NetworkGraphState extends Equatable {
  const NetworkGraphState({
    this.status = NetworkGraphStatus.initial,
    this.scope = GraphScope.personal,
    this.graph,
    this.path,
    this.errorMessage,
  });

  final NetworkGraphStatus status;
  final GraphScope scope;
  final NetworkGraph? graph;
  final NetworkGraphPath? path;
  final String? errorMessage;

  bool get isLoading => status == NetworkGraphStatus.loading;

  NetworkGraphState copyWith({
    NetworkGraphStatus? status,
    GraphScope? scope,
    NetworkGraph? graph,
    NetworkGraphPath? path,
    String? errorMessage,
    bool clearPath = false,
    bool clearError = false,
  }) {
    return NetworkGraphState(
      status: status ?? this.status,
      scope: scope ?? this.scope,
      graph: graph ?? this.graph,
      path: clearPath ? null : (path ?? this.path),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, scope, graph, path, errorMessage];
}
