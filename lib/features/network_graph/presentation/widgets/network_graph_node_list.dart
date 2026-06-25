import 'package:flutter/material.dart';

import '../../domain/entities/graph_node.dart';
import '../../domain/entities/graph_node_type.dart';

class NetworkGraphNodeList extends StatelessWidget {
  const NetworkGraphNodeList({
    super.key,
    required this.nodes,
  });

  final List<GraphNode> nodes;

  @override
  Widget build(BuildContext context) {
    final ordered = [...nodes]..sort((a, b) {
        final degreeCompare = b.degree.compareTo(a.degree);
        if (degreeCompare != 0) return degreeCompare;
        return a.label.compareTo(b.label);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En güçlü düğümler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...ordered.take(12).map(NetworkGraphNodeTile.new),
      ],
    );
  }
}

class NetworkGraphNodeTile extends StatelessWidget {
  const NetworkGraphNodeTile(
    this.node, {
    super.key,
  });

  final GraphNode node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          child: Icon(NetworkGraphNodeIcon.iconFor(node.type), size: 20),
        ),
        title: Text(
          node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          node.subtitle ?? NetworkGraphNodeLabel.labelFor(node.type),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              node.degree.toString(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'bağ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkGraphNodeIcon {
  const NetworkGraphNodeIcon._();

  static IconData iconFor(GraphNodeType type) {
    return switch (type) {
      GraphNodeType.user => Icons.person_outline_rounded,
      GraphNodeType.card => Icons.badge_outlined,
      GraphNodeType.company => Icons.business_outlined,
      GraphNodeType.event => Icons.event_outlined,
      GraphNodeType.organization => Icons.apartment_outlined,
      GraphNodeType.organizationEvent => Icons.groups_outlined,
      GraphNodeType.skill => Icons.auto_awesome_outlined,
      GraphNodeType.location => Icons.place_outlined,
    };
  }
}

class NetworkGraphNodeLabel {
  const NetworkGraphNodeLabel._();

  static String labelFor(GraphNodeType type) {
    return switch (type) {
      GraphNodeType.user => 'Kullanıcı',
      GraphNodeType.card => 'Kart',
      GraphNodeType.company => 'Şirket',
      GraphNodeType.event => 'Etkinlik',
      GraphNodeType.organization => 'Organizasyon',
      GraphNodeType.organizationEvent => 'Organizasyon etkinliği',
      GraphNodeType.skill => 'Yetenek',
      GraphNodeType.location => 'Konum',
    };
  }
}
