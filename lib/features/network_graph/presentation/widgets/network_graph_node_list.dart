import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
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
          AppL10n.strongestNodes(context.l10n),
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
        leading: (node.photoUrl?.trim().isNotEmpty ?? false)
            ? ProfileAvatar(
                photoUrl: node.photoUrl,
                displayName: node.isOwnCard ? context.l10n.you : node.label,
                size: 40,
                circular: true,
              )
            : CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: Icon(NetworkGraphNodeIcon.iconFor(node.type), size: 20),
              ),
        title: Text(
          node.isOwnCard ? context.l10n.you : node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          node.subtitle ?? NetworkGraphNodeLabel.labelFor(context.l10n, node.type),
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
              AppL10n.connectionsCount(context.l10n),
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

  static String labelFor(AppLocalizations l10n, GraphNodeType type) {
    return switch (type) {
      GraphNodeType.user => AppL10n.nodeTypeUser(l10n),
      GraphNodeType.card => AppL10n.nodeTypeCard(l10n),
      GraphNodeType.company => AppL10n.nodeTypeCompany(l10n),
      GraphNodeType.event => AppL10n.nodeTypeEvent(l10n),
      GraphNodeType.organization => AppL10n.nodeTypeOrganization(l10n),
      GraphNodeType.organizationEvent => AppL10n.nodeTypeOrganizationEvent(l10n),
      GraphNodeType.skill => AppL10n.nodeTypeSkill(l10n),
      GraphNodeType.location => AppL10n.nodeTypeLocation(l10n),
    };
  }
}
