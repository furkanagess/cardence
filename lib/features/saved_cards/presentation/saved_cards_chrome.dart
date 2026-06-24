import '../domain/entities/saved_cards_wallet_quota.dart';
import '../../../l10n/app_localizations.dart';

/// [MainShellPage] AppBar ve [SavedCardsPage] gövdesi arasında paylaşılan UI durumu.
class SavedCardsChromeState {
  const SavedCardsChromeState({
    required this.quota,
    required this.displayCount,
    required this.totalCount,
    required this.isDemoMode,
    required this.showFlippableView,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.canAddMore,
  });

  final SavedCardsWalletQuota? quota;
  final int displayCount;
  final int totalCount;
  final bool isDemoMode;
  final bool showFlippableView;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final bool canAddMore;

  String subtitle(AppLocalizations l10n) {
    if (quota == null) return l10n.ykleniyor;
    if (isDemoMode) {
      return '${l10n.ornekKartlar} · ${quota!.remainingSlotsLabel}';
    }
    if (hasActiveFilters) {
      return l10n.cardsShowing(displayCount, totalCount);
    }
    return '${quota!.usedCount} kart · ${quota!.remainingSlotsLabel}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedCardsChromeState &&
            other.quota == quota &&
            other.displayCount == displayCount &&
            other.totalCount == totalCount &&
            other.isDemoMode == isDemoMode &&
            other.showFlippableView == showFlippableView &&
            other.hasActiveFilters == hasActiveFilters &&
            other.activeFilterCount == activeFilterCount &&
            other.canAddMore == canAddMore;
  }

  @override
  int get hashCode => Object.hash(
        quota,
        displayCount,
        totalCount,
        isDemoMode,
        showFlippableView,
        hasActiveFilters,
        activeFilterCount,
        canAddMore,
      );
}
