import 'package:flutter/material.dart';

import '../widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import 'card_detail_page.dart';

/// Kendi kartlarım: kartlar ListView ile listelenir.
class MyCardsPage extends StatelessWidget {
  const MyCardsPage({
    super.key,
    this.draft,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft? draft;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  Widget build(BuildContext context) {
    if (draft == null || _isEmpty(draft!)) {
      return _buildEmptyState(context);
    }
    const padding = 20.0;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: padding),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _MyCardItem(
            draft: draft!,
            persistOnboardingCard: persistOnboardingCard,
            onDraftUpdated: onDraftUpdated,
          ),
        );
      },
    );
  }

  bool _isEmpty(OnboardingCardDraft d) {
    return (d.displayName == null || d.displayName!.trim().isEmpty) &&
        (d.email == null || d.email!.trim().isEmpty) &&
        (d.phone == null || d.phone!.trim().isEmpty) &&
        (d.company == null || d.company!.trim().isEmpty) &&
        (d.title == null || d.title!.trim().isEmpty) &&
        (d.website == null || d.website!.trim().isEmpty) &&
        (d.linkedin == null || d.linkedin!.trim().isEmpty);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_rounded,
              size: 72,
              color: colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz kartın yok',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Onboarding\'de oluşturduğun kart burada listelenecek.',
              style: textTheme.bodyMedium?.copyWith(
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

class _MyCardItem extends StatelessWidget {
  const _MyCardItem({
    required this.draft,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft draft;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  Widget build(BuildContext context) {
    return MyCardPreviewHelpers.flippableCard(
      draft: draft,
      emptyMessage: 'Kart bilgisi yok',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => CardDetailPage(
              draft: draft,
              persistOnboardingCard: persistOnboardingCard,
              onDraftUpdated: onDraftUpdated,
            ),
          ),
        );
      },
    );
  }
}
