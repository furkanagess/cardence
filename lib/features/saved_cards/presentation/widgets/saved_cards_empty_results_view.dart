import 'package:flutter/material.dart';

class SavedCardsEmptyResultsView extends StatelessWidget {
  const SavedCardsEmptyResultsView({
    super.key,
    required this.hasFilters,
    required this.hasSearch,
    required this.onClearFilters,
    required this.onClearSearch,
  });

  final bool hasFilters;
  final bool hasSearch;
  final VoidCallback onClearFilters;
  final VoidCallback onClearSearch;

  bool get _hasConstraints => hasFilters || hasSearch;

  String get _title {
    if (hasFilters && hasSearch) return 'Sonuç bulunamadı';
    if (hasSearch) return 'Aramaya uyan kart yok';
    if (hasFilters) return 'Filtreye uyan kart yok';
    return 'Henüz kayıtlı kart yok';
  }

  String? get _subtitle {
    if (hasFilters && hasSearch) {
      return 'Arama veya filtre kriterlerini değiştirin.';
    }
    if (hasSearch) return 'Farklı bir arama terimi deneyin.';
    if (hasFilters) {
      return 'Farklı filtre deneyin veya filtreleri temizleyin.';
    }
    return null;
  }

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
              _hasConstraints
                  ? Icons.search_off_rounded
                  : Icons.credit_card_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              _title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                _subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            if (hasFilters && hasSearch)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: onClearSearch,
                    child: const Text('Aramayı temizle'),
                  ),
                  OutlinedButton(
                    onPressed: onClearFilters,
                    child: const Text('Filtreleri temizle'),
                  ),
                ],
              )
            else if (hasSearch)
              OutlinedButton(
                onPressed: onClearSearch,
                child: const Text('Aramayı temizle'),
              )
            else if (hasFilters)
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
