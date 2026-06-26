import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/graph_edge.dart';
import '../../domain/entities/graph_edge_type.dart';

class NetworkGraphEdgeList extends StatelessWidget {
  const NetworkGraphEdgeList({
    super.key,
    required this.edges,
  });

  final List<GraphEdge> edges;

  @override
  Widget build(BuildContext context) {
    final ordered = [...edges]..sort((a, b) {
        final weightCompare = b.weight.compareTo(a.weight);
        if (weightCompare != 0) return weightCompare;
        return a.type.name.compareTo(b.type.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.connections,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...ordered.take(16).map(NetworkGraphEdgeTile.new),
      ],
    );
  }
}

class NetworkGraphEdgeTile extends StatelessWidget {
  const NetworkGraphEdgeTile(
    this.edge, {
    super.key,
  });

  final GraphEdge edge;

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              NetworkGraphEdgeIcon.iconFor(edge.type),
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NetworkGraphEdgeLabel.labelFor(context.l10n, edge.type),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${edge.source} → ${edge.target}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('x${edge.weight}'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkGraphEdgeIcon {
  const NetworkGraphEdgeIcon._();

  static IconData iconFor(GraphEdgeType type) {
    return switch (type) {
      GraphEdgeType.owns => Icons.account_circle_outlined,
      GraphEdgeType.saved => Icons.bookmark_added_outlined,
      GraphEdgeType.savedBy => Icons.favorite_border_rounded,
      GraphEdgeType.scanned => Icons.qr_code_scanner_rounded,
      GraphEdgeType.viewed => Icons.visibility_outlined,
      GraphEdgeType.contactClicked => Icons.touch_app_outlined,
      GraphEdgeType.worksAt => Icons.business_center_outlined,
      GraphEdgeType.metAtEvent => Icons.event_available_outlined,
      GraphEdgeType.coSaved => Icons.hub_outlined,
      GraphEdgeType.sameCompany => Icons.domain_outlined,
      GraphEdgeType.assignedLead => Icons.assignment_ind_outlined,
      GraphEdgeType.orgEventLink => Icons.groups_2_outlined,
    };
  }
}

class NetworkGraphEdgeLabel {
  const NetworkGraphEdgeLabel._();

  static String labelFor(AppLocalizations l10n, GraphEdgeType type) {
    return switch (type) {
      GraphEdgeType.owns => l10n.edgeTypeOwns,
      GraphEdgeType.saved => l10n.edgeTypeSaved,
      GraphEdgeType.savedBy => l10n.edgeTypeSavedBy,
      GraphEdgeType.scanned => l10n.edgeTypeScanned,
      GraphEdgeType.viewed => l10n.edgeTypeViewed,
      GraphEdgeType.contactClicked => l10n.edgeTypeContactClicked,
      GraphEdgeType.worksAt => l10n.edgeTypeWorksAt,
      GraphEdgeType.metAtEvent => l10n.edgeTypeMetAtEvent,
      GraphEdgeType.coSaved => l10n.edgeTypeCoSaved,
      GraphEdgeType.sameCompany => l10n.edgeTypeSameCompany,
      GraphEdgeType.assignedLead => l10n.edgeTypeAssignedLead,
      GraphEdgeType.orgEventLink => l10n.edgeTypeOrgEventLink,
    };
  }
}
