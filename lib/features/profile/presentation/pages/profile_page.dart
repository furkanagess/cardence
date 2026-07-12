import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/molecules/card_index_circle_selector.dart';
import '../widgets/profile_quick_actions.dart';
import '../../../my_cards/presentation/pages/my_card_edit_page.dart';
import '../../../my_cards/presentation/helpers/my_card_slot_counts.dart';
import '../../../my_cards/presentation/widgets/empty_card_slot_preview.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../onboarding/presentation/helpers/additional_card_onboarding_launcher.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../../saved_cards/presentation/pages/saved_card_detail_page.dart';
import '../helpers/profile_own_card_preview_mapper.dart';
import '../../../settings/presentation/pages/card_visibility_settings_page.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../network_graph/presentation/helpers/network_graph_launcher.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../onboarding/presentation/widgets/onboarding_card_preview_frame.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../domain/entities/profile_stats.dart';
import '../../../plans/domain/entities/plan_entitlements.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../plans/presentation/cubit/plan_state.dart';
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
    required this.uploadProfilePhoto,
    required this.upgradeWalletPlan,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft? draft;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final GetProfileStats getProfileStats;
  final GetNetworkGraph getNetworkGraph;
  final GetNetworkGraphPath getNetworkGraphPath;
  final GetEventGroups getEventGroups;
  final UploadProfilePhoto uploadProfilePhoto;
  final UpgradeWalletPlan upgradeWalletPlan;
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
      final slotCounts = resolveMyCardSlotCounts(
        cardCount: list.length,
        plan: plan,
      );
      setState(() {
        _cards = list;
        _stats = stats;
        _canAddBusinessCard =
            maxBusinessCards == null || list.length < maxBusinessCards;
        _isPremium = plan?.isPremiumOrHigher ?? false;
        if (_selectedIndex >= slotCounts.unlockedSlots) {
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

  Future<OnboardingCardDraft?> _openCardEditor(
    OnboardingCardDraft card, {
    bool isNew = false,
  }) async {
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
    if (!mounted) return result;
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
    return result;
  }

  Future<void> _openCardDetail(
    OnboardingCardDraft card, {
    String? heroTag,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedCardDetailPage(
          card: profileOwnCardPreviewFromDraft(
            card,
            isOwnerPremium: _isPremium,
          ),
          heroTag: heroTag,
          readOnly: true,
          getEventGroups: widget.getEventGroups,
          onSave: (_) async {},
          onEdit: () async {
            final updated = await _openCardEditor(card);
            if (updated == null) return null;
            return profileOwnCardPreviewFromDraft(
              updated,
              isOwnerPremium: _isPremium,
            );
          },
        ),
      ),
    );
    if (!mounted) return;
    await _loadPageData();
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
    await _openAdditionalCardOnboarding(newCard);
  }

  Future<void> _openAdditionalCardOnboarding(OnboardingCardDraft card) async {
    final result = await AdditionalCardOnboardingLauncher.open(
      context,
      initialDraft: card,
      persistOnboardingCard: widget.persistOnboardingCard,
      uploadProfilePhoto: widget.uploadProfilePhoto,
      upgradeWalletPlan: widget.upgradeWalletPlan,
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

  Future<void> _openLockedSlotPaywall() async {
    if (!mounted) return;
    await WalletPaywallFlow.show(
      context,
      cubit: context.read<SavedCardsCubit>(),
    );
    if (!mounted) return;
    await context.read<PlanCubit>().refresh();
    await _loadPageData();
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

    return BlocListener<PlanCubit, PlanState>(
      listenWhen: (previous, current) =>
          (previous.entitlements?.isPremiumOrHigher ?? false) !=
          (current.entitlements?.isPremiumOrHigher ?? false),
      listener: (_, __) => _loadPageData(),
      child: RefreshIndicator(
        onRefresh: _loadPageData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 32 + bottomInset),
          children: [
            if (_cards.isEmpty && !_canAddBusinessCard)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEmptyState(colorScheme, textTheme),
              ),
          if (_cards.isNotEmpty || _canAddBusinessCard) ...[
            _ProfileCardsCarousel(
              cards: _cards,
              pageController: _pageController,
              selectedIndex: _selectedIndex,
              plan: context.watch<PlanCubit>().state.entitlements,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              onCardTap: (card, {heroTag}) => _openCardDetail(card, heroTag: heroTag),
              onLockedSlotTap: _openLockedSlotPaywall,
              onAddCard: _createNewCard,
            ),
          ],
          if (_cards.isNotEmpty || !_canAddBusinessCard)
            Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ProfileQuickActions(
              limitHint: !_canAddBusinessCard
                  ? AppL10n.cardLimitReachedPremiumUpgrade(context.l10n)
                  : null,
              cardLayoutLabel: _cards.isNotEmpty
                  ? context.l10n.kartGrnm
                  : null,
              onCardLayout: _cards.isNotEmpty
                  ? () {
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
                    }
                  : null,
              networkGraphLabel:
                  _cards.isNotEmpty ? context.l10n.agGrafigi : null,
              onNetworkGraph: _cards.isNotEmpty ? _openNetworkGraph : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ProfileInteractionStats(
              eventGroupCount: stats.eventGroupCount,
              totalWalletSaveCount: stats.totalWalletSaveCount,
            ),
          ),
        ],
      ),
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
    required this.plan,
    required this.onPageChanged,
    required this.onCardTap,
    required this.onLockedSlotTap,
    required this.onAddCard,
  });

  final List<OnboardingCardDraft> cards;
  final PageController pageController;
  final int selectedIndex;
  final PlanEntitlements? plan;
  final ValueChanged<int> onPageChanged;
  final void Function(OnboardingCardDraft card, {String? heroTag}) onCardTap;
  final VoidCallback onLockedSlotTap;
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final cardWidth = pageWidth * _profileCarouselViewportFraction;
        final carouselHeight =
            OnboardingCardPreviewFrame.heightForWidth(cardWidth) +
                _profileCarouselVerticalPadding * 2;
        const selectorSpacing = 12.0;
        final slotCounts = resolveMyCardSlotCounts(
          cardCount: cards.length,
          plan: plan,
        );
        final isEmptySlotSelected = selectedIndex >= cards.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CardIndexCircleSelector(
                  axis: Axis.horizontal,
                  unlockedCount: slotCounts.unlockedSlots,
                  filledCount: slotCounts.filledCount,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    onPageChanged(index);
                    if (pageController.hasClients &&
                        index < cards.length &&
                        cards.length > 1) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  onLockedTap: onLockedSlotTap,
                ),
              ),
              const SizedBox(height: selectorSpacing),
              SizedBox(
                height: carouselHeight,
                child: isEmptySlotSelected
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _profileCarouselHorizontalPadding,
                          vertical: _profileCarouselVerticalPadding,
                        ),
                        child: EmptyCardSlotPreview(
                          label: context.l10n.yeniKartOlutur,
                          onTap: onAddCard,
                        ),
                      )
                    : cards.length == 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _profileCarouselHorizontalPadding,
                          vertical: _profileCarouselVerticalPadding,
                        ),
                        child: OnboardingCardPreviewFrame(
                          draft: cards.first,
                          heroTag: FlippablePersonCard.heroTagForCardId(
                            cards.first.cardId,
                            scope: FlippablePersonCard.heroScopeProfile,
                          ),
                          onDetailTap: () => onCardTap(
                            cards.first,
                            heroTag: FlippablePersonCard.heroTagForCardId(
                              cards.first.cardId,
                              scope: FlippablePersonCard.heroScopeProfile,
                            ),
                          ),
                          contactFieldsTappable: true,
                          emptyMessage: context.l10n.alanlarDoldukaGrnr,
                          normalizeForDisplay: true,
                          gatePremiumEffects: true,
                        ),
                      )
                    : PageView.builder(
                        controller: pageController,
                        itemCount: cards.length,
                        onPageChanged: onPageChanged,
                        padEnds: false,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final heroTag =
                              FlippablePersonCard.heroTagForCardId(
                            card.cardId,
                            scope: FlippablePersonCard.heroScopeProfile,
                          );
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
                                heroTag: heroTag,
                                onDetailTap: () => onCardTap(
                                  card,
                                  heroTag: heroTag,
                                ),
                                contactFieldsTappable: true,
                                emptyMessage: context.l10n.alanlarDoldukaGrnr,
                                normalizeForDisplay: true,
                                gatePremiumEffects: true,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
