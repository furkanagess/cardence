import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../my_cards/presentation/pages/card_view_page.dart';
import '../../../my_cards/presentation/pages/my_card_edit_page.dart';
import '../../../my_cards/presentation/widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../onboarding/domain/usecases/save_onboarding_draft_card.dart';

const double _profileCarouselViewportFraction = 0.88;
const double _profileCarouselHorizontalPadding = 12;
const double _profileCarouselVerticalPadding = 14;

/// Profil: kullanicinin kartlari yatay carousel ile listelenir.
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.draft,
    required this.getOnboardingDraftCards,
    required this.saveOnboardingDraftCard,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft? draft;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<OnboardingCardDraft> _cards = [];
  bool _loading = true;
  int _selectedIndex = 0;
  late final PageController _pageController = PageController(
    viewportFraction: _profileCarouselViewportFraction,
  );

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    try {
      final list = await widget.getOnboardingDraftCards();
      if (!mounted) return;
      setState(() {
        _cards = list;
        if (_selectedIndex >= list.length) {
          _selectedIndex = list.isEmpty ? 0 : list.length - 1;
        }
        _loading = false;
      });
      if (_cards.length > 1 && _selectedIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_pageController.hasClients) return;
          _pageController.jumpToPage(
            _selectedIndex.clamp(0, _cards.length - 1),
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cards = [];
        _loading = false;
      });
    }
  }

  OnboardingCardDraft? get _selectedCard {
    if (_cards.isEmpty) return null;
    return _cards[_selectedIndex.clamp(0, _cards.length - 1)];
  }

  Future<void> _openCardEditor(OnboardingCardDraft card, {bool isNew = false}) async {
    final result = await Navigator.of(context).push<OnboardingCardDraft>(
      MaterialPageRoute(
        builder: (context) => MyCardEditPage(
          initialDraft: card,
          isNewCard: isNew,
          saveOnboardingDraftCard: widget.saveOnboardingDraftCard,
          onDraftUpdated: widget.onDraftUpdated,
        ),
      ),
    );
    if (!mounted) return;
    await _loadCards();
    if (result != null) {
      widget.onDraftUpdated?.call(result);
      final idx = _cards.indexWhere((c) => c.cardId == result.cardId);
      if (idx >= 0) {
        setState(() => _selectedIndex = idx);
        if (_pageController.hasClients && _cards.length > 1) {
          _pageController.animateToPage(
            idx,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  Future<void> _createNewCard() async {
    final template = _cards.isNotEmpty ? _cards.first : widget.draft;
    final base = template ?? const OnboardingCardDraft();
    final newCard = base.copyWith(
      cardId: const Uuid().v4(),
      cardName: 'Yeni kart',
      frontVisibleFields: base.shouldMigrateFrontFields
          ? List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields)
          : List.from(base.frontVisibleFields),
      backVisibleFields: base.backVisibleFields.isEmpty
          ? List<String>.from(
              OnboardingCardDraft.backFieldKeys.take(3),
            )
          : List.from(base.backVisibleFields),
    );
    await _openCardEditor(newCard, isNew: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadCards,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kartlarım',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _cards.length > 1
                      ? 'Yatay kaydırarak kartlar arasında geçin; düzenlemek için karta dokunun.'
                      : 'Düzenlemek için karta dokunun.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_cards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildEmptyState(colorScheme, textTheme),
            ),
          if (_cards.isNotEmpty) ...[
            _ProfileCardsCarousel(
              cards: _cards,
              pageController: _pageController,
              selectedIndex: _selectedIndex,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              onCardTap: _openCardEditor,
            ),
            const SizedBox(height: 12),
            _ProfileCarouselFooter(
              card: _selectedCard!,
              cardCount: _cards.length,
              selectedIndex: _selectedIndex,
              onEdit: () => _openCardEditor(_selectedCard!),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FilledButton.icon(
              onPressed: _createNewCard,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text('Yeni kart'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          if (_cards.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (context) => CardViewPage(
                            getOnboardingDraftCards:
                                widget.getOnboardingDraftCards,
                            saveOnboardingDraftCard:
                                widget.saveOnboardingDraftCard,
                            onDraftUpdated: widget.onDraftUpdated,
                          ),
                        ),
                      )
                      .then((_) => _loadCards());
                },
                icon: const Icon(Icons.view_carousel_outlined, size: 20),
                label: const Text('Kart yüzü ve alan düzeni'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 48,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kartınız yok',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'İlk kartınızı oluşturun; iş, etkinlik veya kişisel kullanım için ayrı kartlar ekleyebilirsiniz.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCardsCarousel extends StatelessWidget {
  const _ProfileCardsCarousel({
    required this.cards,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onCardTap,
  });

  final List<OnboardingCardDraft> cards;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final void Function(OnboardingCardDraft card) onCardTap;

  @override
  Widget build(BuildContext context) {
    const carouselHeight = FlippablePersonCard.fixedHeight +
        _profileCarouselVerticalPadding * 2;

    if (cards.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _profileCarouselHorizontalPadding + 8,
        ),
        child: SizedBox(
          height: carouselHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: _profileCarouselVerticalPadding,
            ),
            child: MyCardPreviewHelpers.flippableCard(
              draft: cards.first,
              onTap: () => onCardTap(cards.first),
              emptyMessage: 'Kart bilgisi yok — düzenlemek için dokunun',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: cards.length,
        onPageChanged: onPageChanged,
        padEnds: false,
        itemBuilder: (context, index) {
          final card = cards[index];
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double t = 0;
              if (pageController.position.haveDimensions) {
                final page =
                    pageController.page ?? pageController.initialPage.toDouble();
                t = (page - index).abs().clamp(0.0, 1.0);
              }
              const maxScaleDelta = 0.06;
              const maxFadeDelta = 0.18;
              final scale = 1.0 - (t * maxScaleDelta);
              final opacity = 1.0 - (t * maxFadeDelta);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _profileCarouselHorizontalPadding,
                vertical: _profileCarouselVerticalPadding,
              ),
              child: MyCardPreviewHelpers.flippableCard(
                key: ValueKey(card.cardId),
                draft: card,
                onTap: () => onCardTap(card),
                emptyMessage: 'Kart bilgisi yok — düzenlemek için dokunun',
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCarouselFooter extends StatelessWidget {
  const _ProfileCarouselFooter({
    required this.card,
    required this.cardCount,
    required this.selectedIndex,
    required this.onEdit,
  });

  final OnboardingCardDraft card;
  final int cardCount;
  final int selectedIndex;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (cardCount > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cardCount, (index) {
                final isActive = index == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.listTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.listSubtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.listSubtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Düzenle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
