import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

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

  String _title(BuildContext context) {
    final l10n = context.l10n;
    if (hasFilters && hasSearch) return l10n.sonuBulunamad;
    if (hasSearch) return l10n.aramayaUyanKartYok;
    if (hasFilters) return l10n.filtreyeUyanKartYok;
    return l10n.henzKaytlKartYok;
  }

  String? _subtitle(BuildContext context) {
    final l10n = context.l10n;
    if (hasFilters && hasSearch) {
      return l10n.aramaVeyaFiltreKriterleriniDeitirin;
    }
    if (hasSearch) return l10n.farklBirAramaTerimiDeneyin;
    if (hasFilters) {
      return l10n.farklFiltreDeneyinVeyaFiltreleri;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _subtitle(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_page_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _title(context),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_hasConstraints) ...[
              const SizedBox(height: 20),
              if (hasSearch)
                CustomButton.text(
                  label: context.l10n.aramayTemizle,
                  onPressed: onClearSearch,
                ),
              if (hasFilters)
                CustomButton.text(
                  label: context.l10n.filtreleriTemizle,
                  onPressed: onClearFilters,
                ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.sagAlttakiEkleIleQr,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
