import 'package:flutter/material.dart';

class NetworkGraphEmptyState extends StatelessWidget {
  const NetworkGraphEmptyState({
    super.key,
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 16),
            Text(
              'Ağ grafiği henüz oluşmadı',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kart kaydettikçe, QR okutuldukça ve etkinlik grupları kullandıkça bağlantılar burada görünür.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yenile'),
            ),
          ],
        ),
      ),
    );
  }
}
