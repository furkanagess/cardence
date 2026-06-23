import 'package:flutter/material.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../my_cards/presentation/pages/my_card_edit_page.dart';
import '../../../settings/presentation/pages/card_visibility_settings_page.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../domain/entities/profile_stats.dart';
import '../../../saved_cards/domain/entities/saved_cards_wallet_quota.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../domain/usecases/get_profile_stats.dart';
import '../widgets/profile_interaction_stats.dart';

const double _profileCarouselViewportFraction = 0.88;
const double _profileCarouselHorizontalPadding = 12;
const double _profileCarouselVerticalPadding = 14;

/// Profil: kart carousel, aksiyonlar ve etkileşim istatistikleri.
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.draft,
    required this.getOnboardingDraftCards,
    required this.persistOnboardingCard,
    required this.getProfileStats,
    required this.getSavedCardsWalletQuota,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft? draft;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final GetProfileStats getProfileStats;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<OnboardingCardDraft> _cards = [];
  ProfileStats? _stats;
  bool _loading = true;
  bool _canAddBusinessCard = true;
  bool _isPremium = false;
  int _selectedIndex = 0;
  late final PageController _pageController = PageController(
    viewportFraction: _profileCarouselViewportFraction,
  );

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.getOnboardingDraftCards(),
        widget.getProfileStats(),
        widget.getSavedCardsWalletQuota(),
      ]);
      if (!mounted) return;
      final list = results[0] as List<OnboardingCardDraft>;
      final stats = results[1] as ProfileStats;
      final quota = results[2] as SavedCardsWalletQuota;
      setState(() {
        _cards = list;
        _stats = stats;
        _canAddBusinessCard = quota.canAddBusinessCard;
        _isPremium = quota.isPremium;
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
        _stats = const ProfileStats(
          totalWalletSaveCount: 0,
          eventGroupCount: 0,
        );
        _canAddBusinessCard = true;
        _isPremium = false;
        _loading = false;
      });
    }
  }

  Future<void> _openCardEditor(OnboardingCardDraft card, {bool isNew = false}) async {
    final result = await Navigator.of(context).push<OnboardingCardDraft>(
      MaterialPageRoute(
        builder: (context) => MyCardEditPage(
          initialDraft: card,
          isNewCard: isNew,
          persistOnboardingCard: widget.persistOnboardingCard,
          onDraftUpdated: widget.onDraftUpdated,
        ),
      ),
    );
    if (!mounted) return;
    await _loadPageData();
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
    if (!_canAddBusinessCard) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ücretsiz planda yalnızca 1 kart oluşturabilirsiniz. Premium ile daha fazla kart ekleyin.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final template = _cards.isNotEmpty ? _cards.first : widget.draft;
    final base = template ?? const OnboardingCardDraft();
    final newCard = base.copyWith(
      cardId: CardIdGenerator.generateBusinessCandidate(),
      cardName: 'Yeni kart',
      frontVisibleFields: base.shouldMigrateFrontFields
          ? List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields)
          : List.from(base.frontVisibleFields),
      backVisibleFields: base.backVisibleFields.isEmpty
          ? List<String>.from(OnboardingCardDraft.defaultBackVisibleFields)
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

    final stats = _stats ??
        const ProfileStats(totalWalletSaveCount: 0, eventGroupCount: 0);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 96;

    return RefreshIndicator(
      onRefresh: _loadPageData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(0, 8, 0, 32 + bottomInset),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              _cards.length > 1
                  ? 'Yatay kaydırarak kartlar arasında geçin; düzenlemek için karta çift dokunun.'
                  : 'Düzenlemek için karta çift dokunun.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
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
              showPremiumBadge: _isPremium,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              onCardTap: _openCardEditor,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CustomButton(
              label: 'Yeni kart',
              icon: Icons.add_rounded,
              onPressed: _createNewCard,
            ),
          ),
          if (!_canAddBusinessCard) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Ücretsiz planda tek kart oluşturabilirsiniz. Premium ile daha fazla kart ekleyin.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_cards.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton.tonal(
                label: 'Kart yüzü ve alan düzeni',
                icon: Icons.view_carousel_outlined,
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (context) => CardVisibilitySettingsPage(
                            getOnboardingDraftCards:
                                widget.getOnboardingDraftCards,
                            persistOnboardingCard:
                                widget.persistOnboardingCard,
                            onDraftUpdated: widget.onDraftUpdated,
                          ),
                        ),
                      )
                      .then((_) => _loadPageData());
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: ProfileInteractionStats(
              eventGroupCount: stats.eventGroupCount,
              totalWalletSaveCount: stats.totalWalletSaveCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
    required this.showPremiumBadge,
    required this.onPageChanged,
    required this.onCardTap,
  });

  final List<OnboardingCardDraft> cards;
  final PageController pageController;
  final int selectedIndex;
  final bool showPremiumBadge;
  final ValueChanged<int> onPageChanged;
  final void Function(OnboardingCardDraft card) onCardTap;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final cardWidth = pageWidth * _profileCarouselViewportFraction;
        final carouselHeight =
            OnboardingCardPreviewFrame.heightForWidth(cardWidth) +
                _profileCarouselVerticalPadding * 2;

        if (cards.length == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: carouselHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _profileCarouselVerticalPadding,
                ),
                child: OnboardingCardPreviewFrame(
                  draft: cards.first,
                  onDoubleTap: () => onCardTap(cards.first),
                  emptyMessage: 'Alanlar doldukça görünür',
                  normalizeForDisplay: true,
                  showPremiumBadge: showPremiumBadge,
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
                    final page = pageController.page ??
                        pageController.initialPage.toDouble();
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
                  child: OnboardingCardPreviewFrame(
                    key: ValueKey(card.cardId),
                    draft: card,
                    onDoubleTap: () => onCardTap(card),
                    emptyMessage: 'Alanlar doldukça görünür',
                    normalizeForDisplay: true,
                    showPremiumBadge: showPremiumBadge,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
