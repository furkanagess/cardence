import '../domain/entities/saved_cards_wallet_quota.dart';

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

  String get subtitle {
    if (quota == null) return 'Yükleniyor…';
    if (isDemoMode) {
      return 'Örnek kartlar · ${quota!.remainingSlotsLabel}';
    }
    if (hasActiveFilters) {
      return '$displayCount / $totalCount kart gösteriliyor';
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
