import 'package:flutter/material.dart';

import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../domain/entities/graph_scope.dart';
import '../../domain/usecases/get_network_graph.dart';
import '../../domain/usecases/get_network_graph_path.dart';
import '../pages/network_graph_page.dart';

class NetworkGraphLauncher {
  const NetworkGraphLauncher._();

  static Future<void> open(
    BuildContext context, {
    required GetNetworkGraph getNetworkGraph,
    required GetNetworkGraphPath getNetworkGraphPath,
    required GetEventGroups getEventGroups,
    String? centerCardId,
    GraphScope initialScope = GraphScope.personal,
    String? eventGroupId,
    String? eventGroupName,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => NetworkGraphPage(
          getNetworkGraph: getNetworkGraph,
          getNetworkGraphPath: getNetworkGraphPath,
          getEventGroups: getEventGroups,
          centerCardId: centerCardId,
          initialScope: initialScope,
          initialEventGroupId: eventGroupId,
          initialEventGroupName: eventGroupName,
        ),
      ),
    );
  }
}
