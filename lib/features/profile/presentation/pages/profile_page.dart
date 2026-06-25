import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../my_cards/presentation/pages/my_card_edit_page.dart';
import '../../../settings/presentation/pages/card_visibility_settings_page.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../network_graph/presentation/helpers/network_graph_launcher.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../domain/entities/profile_stats.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/wallet_paywall_flow.dart';
import '../../domain/usecases/get_profile_stats.dart';
import '../widgets/profile_interaction_stats.dart';
import '../widgets/profile_loading_shimmer.dart';

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
    required this.getNetworkGraph,
    required this.getNetworkGraphPath,
    required this.getEventGroups,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft? draft;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final GetProfileStats getProfileStats;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final GetEventGroups getEventGroups;
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
      final planCubit = context.read<PlanCubit>();
      final results = await Future.wait([
        widget.getOnboardingDraftCards(),
        widget.getProfileStats(),
      ]);
      if (planCubit.state.entitlements == null) {
        await planCubit.refresh();
      }
      if (!mounted) return;
      final list = results[0] as List<OnboardingCardDraft>;
      final stats = results[1] as ProfileStats;
      final plan = planCubit.state.entitlements;
      final maxBusinessCards = plan?.limits.maxBusinessCards;
      setState(() {
        _cards = list;
        _stats = stats;
        _canAddBusinessCard =
            maxBusinessCards == null || list.length < maxBusinessCards;
        _isPremium = plan?.isPremiumOrHigher ?? false;
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

  Future<void> _openCardEditor(OnboardingCardDraft card,
      {bool isNew = false}) async {
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
      await WalletPaywallFlow.show(
        context,
        cubit: context.read<SavedCardsCubit>(),
      );
      if (!mounted) return;
      await context.read<PlanCubit>().refresh();
      await _loadPageData();
      return;
    }

    final template = _cards.isNotEmpty ? _cards.first : widget.draft;
    final base = template ?? const OnboardingCardDraft();
    final newCard = base.copyWith(
      cardId: CardIdGenerator.generateBusinessCandidate(),
      cardName: context.l10n.yeniKart,
      frontVisibleFields: base.shouldMigrateFrontFields
          ? List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields)
          : List.from(base.frontVisibleFields),
      backVisibleFields: base.backVisibleFields.isEmpty
          ? List<String>.from(OnboardingCardDraft.defaultBackVisibleFields)
          : List.from(base.backVisibleFields),
    );
    await _openCardEditor(newCard, isNew: true);
  }

  Future<void> _openNetworkGraph() async {
    await NetworkGraphLauncher.open(
      context,
      getNetworkGraph: widget.getNetworkGraph,
      getNetworkGraphPath: widget.getNetworkGraphPath,
      getEventGroups: widget.getEventGroups,
      centerCardId: _cards.isEmpty
          ? null
          : _cards[_selectedIndex].cardId?.trim().isEmpty == true
              ? null
              : _cards[_selectedIndex].cardId?.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const ProfileLoadingShimmer();
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
                  ? 'Yatay kaydırarak kartlar arasında geçin; düzenlemek için karta dokunun.'
                  : 'Düzenlemek için karta dokunun.',
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
              label: context.l10n.yeniKart,
              icon: Icons.add_rounded,
              onPressed: _createNewCard,
            ),
          ),
          if (!_canAddBusinessCard) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Kart limitine ulaştınız. Yeni kart oluşturmak için Premium\'a geçebilirsiniz.',
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
                label: context.l10n.kartYzVeAlanDzeni,
                icon: Icons.view_carousel_outlined,
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (context) => CardVisibilitySettingsPage(
                            getOnboardingDraftCards:
                                widget.getOnboardingDraftCards,
                            persistOnboardingCard: widget.persistOnboardingCard,
                            onDraftUpdated: widget.onDraftUpdated,
                          ),
                        ),
                      )
                      .then((_) => _loadPageData());
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton.tonal(
                label: 'Ağ grafiğini görüntüle',
                icon: Icons.hub_outlined,
                onPressed: _openNetworkGraph,
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
              context.l10n.henzKartnzYok,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.ilkKartnzOluturunIEtkinlik,
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
                  onTap: () => onCardTap(cards.first),
                  contactFieldsTappable: false,
                  emptyMessage: context.l10n.alanlarDoldukaGrnr,
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
                    onTap: () => onCardTap(card),
                    contactFieldsTappable: false,
                    emptyMessage: context.l10n.alanlarDoldukaGrnr,
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
