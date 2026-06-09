import 'package:flutter/material.dart';

class SavedCardsEmptyResultsView extends StatelessWidget {
  const SavedCardsEmptyResultsView({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off_rounded : Icons.credit_card_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'Filtreye uyan kart yok' : 'Henüz kayıtlı kart yok',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Farklı filtre deneyin veya filtreleri temizleyin.'
                  : 'QR okutarak veya kart ID girerek ilk kartınızı ekleyin.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (hasFilters)
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Filtreleri temizle'),
              )
            else
              Text(
                'Sağ alttaki Ekle ile QR okutun veya kart ID girin',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
