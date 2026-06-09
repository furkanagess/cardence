import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/save_event_groups.dart';
import '../../../saved_cards/domain/usecases/add_saved_card.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../../event_groups/presentation/pages/event_groups_page.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_card.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../saved_cards/presentation/pages/saved_cards_page.dart';
import '../../../settings/domain/entities/theme_preference.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Ana kabuk: 2 ekran bottom nav ile (ikon only); Ayarlar AppBar'dan.
class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    required this.getOnboardingDraftCard,
    required this.getOnboardingDraftCards,
    required this.persistOnboardingCard,
    required this.getEventGroups,
    required this.saveEventGroups,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.deleteSavedCard,
    required this.upgradeWalletPlan,
    required this.themePreference,
    required this.onThemeChanged,
    required this.onLogout,
  });

  final GetOnboardingDraftCard getOnboardingDraftCard;
  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final GetEventGroups getEventGroups;
  final SaveEventGroups saveEventGroups;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
  final ThemePreference themePreference;
  final ValueChanged<ThemePreference> onThemeChanged;
  final Future<void> Function() onLogout;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  OnboardingCardDraft? _myCardDraft;
  bool _showSavedCardsFlippableView = true;
  int _savedCardsFilterTrigger = 0;
  int _savedCardsAddCardTrigger = 0;
  int _eventGroupsCreateTrigger = 0;

  @override
  void initState() {
    super.initState();
    _loadMyCardDraft();
  }

  Future<void> _loadMyCardDraft() async {
    final draft = await widget.getOnboardingDraftCard();
    if (!mounted) return;
    setState(() => _myCardDraft = draft);
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Kaydedilen Kartlar';
      case 1:
        return 'Etkinlik grupları';
      case 2:
        return 'Profil';
      default:
        return AppConstants.appName;
    }
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (_currentIndex == 0) return null;

    return CardenceAppBar(
      variant: CardenceAppBarVariant.root,
      title: _appBarTitle,
      leading: _currentIndex == 1
          ? CardenceAppBar.iconAction(
              icon: Icons.add_rounded,
              tooltip: 'Yeni etkinlik grubu',
              onPressed: () {
                setState(() => _eventGroupsCreateTrigger++);
              },
            )
          : null,
      actions: [
        CardenceAppBar.iconAction(
          icon: Icons.settings_outlined,
          tooltip: 'Ayarlar',
          onPressed: () => _openSettings(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardenceScaffold(
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SavedCardsPage(
            getSavedCards: widget.getSavedCards,
            saveSavedCard: widget.saveSavedCard,
            getEventGroups: widget.getEventGroups,
            saveEventGroups: widget.saveEventGroups,
            getSavedCardsWalletQuota: widget.getSavedCardsWalletQuota,
            addSavedCard: widget.addSavedCard,
            deleteSavedCard: widget.deleteSavedCard,
            upgradeWalletPlan: widget.upgradeWalletPlan,
            showFlippableView: _showSavedCardsFlippableView,
            onViewModeChanged: (flippable) =>
                setState(() => _showSavedCardsFlippableView = flippable),
            filterTrigger: _savedCardsFilterTrigger,
            addCardTrigger: _savedCardsAddCardTrigger,
          ),
          EventGroupsPage(
            getEventGroups: widget.getEventGroups,
            saveEventGroups: widget.saveEventGroups,
            getSavedCards: widget.getSavedCards,
            saveSavedCard: widget.saveSavedCard,
            deleteSavedCard: widget.deleteSavedCard,
            createGroupTrigger: _eventGroupsCreateTrigger,
          ),
          ProfilePage(
            draft: _myCardDraft,
            getOnboardingDraftCards: widget.getOnboardingDraftCards,
            persistOnboardingCard: widget.persistOnboardingCard,
            onDraftUpdated: (updated) => setState(() => _myCardDraft = updated),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: _LiquidGlassBottomNavBar(
            currentIndex: _currentIndex,
            itemCount: 3,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsPage(
          currentTheme: widget.themePreference,
          onThemeChanged: widget.onThemeChanged,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }
}

/// Bottom nav: opak yüzey, sliding pill indicator.
class _LiquidGlassBottomNavBar extends StatefulWidget {
  const _LiquidGlassBottomNavBar({
    required this.currentIndex,
    required this.itemCount,
    required this.onTap,
  });

  final int currentIndex;
  final int itemCount;
  final ValueChanged<int> onTap;

  @override
  State<_LiquidGlassBottomNavBar> createState() =>
      _LiquidGlassBottomNavBarState();
}

class _LiquidGlassBottomNavBarState extends State<_LiquidGlassBottomNavBar> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(_LiquidGlassBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) setState(() => _previousIndex = widget.currentIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navSurface = colorScheme.surface;
    final borderColor = colorScheme.outline;
    final pillColor = colorScheme.inverseSurface;
    final selectedIconColor = colorScheme.onInverseSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth = constraints.maxWidth;
        final itemWidth = navWidth / widget.itemCount;
        const indicatorPadding = 6.0;
        final indicatorWidth = itemWidth - (indicatorPadding * 2);

        return SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: navSurface,
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: _previousIndex.toDouble(),
                  end: widget.currentIndex.toDouble(),
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final left = (value * itemWidth) + indicatorPadding;
                  return Positioned(
                    left: left,
                    top: 4,
                    bottom: 4,
                    width: indicatorWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: pillColor,
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.people_outline_rounded,
                        selected: widget.currentIndex == 0,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(0),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.event_note_rounded,
                        selected: widget.currentIndex == 1,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(1),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_rounded,
                        selected: widget.currentIndex == 2,
                        selectedColor: selectedIconColor,
                        onTap: () => widget.onTap(2),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final unselectedColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: selected ? 22 : 18,
            color: selected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
