import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/network_graph_path.dart';
import 'network_graph_node_list.dart';

class NetworkGraphPathCard extends StatelessWidget {
  const NetworkGraphPathCard({
    super.key,
    required this.path,
    required this.isLoading,
    this.pathSourceLabel,
    this.onClear,
  });

  final NetworkGraphPath? path;
  final bool isLoading;
  final String? pathSourceLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.graphNodeLabelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.graphNodeLabelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppL10n.connectionPath(l10n),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                if (path != null || pathSourceLabel != null)
                  IconButton(
                    tooltip: AppL10n.clear(l10n),
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (pathSourceLabel != null && path == null)
              Text(
                AppL10n.selectDestinationCard(l10n, pathSourceLabel!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.35,
                ),
              )
            else if (path != null && !path!.found)
              Text(
                AppL10n.noPathFoundBetweenCards(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.35,
                ),
              )
            else if (path != null && path!.found) ...[
              Text(
                AppL10n.pathStepsAndNodes(
                  l10n,
                  path!.length,
                  path!.pathNodeIds.length,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 12),
              ...path!.nodes.map(NetworkGraphNodeTile.new),
            ]
            else
              Text(
                AppL10n.tapTwoNodesToFindPath(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
