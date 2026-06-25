import 'package:flutter/material.dart';

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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
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
                    'Bağlantı yolu',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (path != null || pathSourceLabel != null)
                  IconButton(
                    tooltip: 'Temizle',
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
                'Hedef kart seçin: $pathSourceLabel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              )
            else if (path != null && !path!.found)
              Text(
                'Seçilen kartlar arasında bu grafikte doğrudan bir yol bulunamadı.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              )
            else if (path != null && path!.found) ...[
              Text(
                '${path!.length} adım • ${path!.pathNodeIds.length} düğüm',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ...path!.nodes.map(NetworkGraphNodeTile.new),
            ]
            else
              Text(
                'İki kart düğümüne dokunarak aralarındaki en kısa yolu bulun.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
