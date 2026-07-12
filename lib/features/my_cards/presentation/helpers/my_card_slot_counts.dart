import '../../../../core/widgets/molecules/card_index_circle_selector.dart';
import '../../../plans/domain/entities/plan_entitlements.dart';

/// Kendi kart slot seçicisi için açık / dolu slot sayıları.
({int unlockedSlots, int filledCount}) resolveMyCardSlotCounts({
  required int cardCount,
  required PlanEntitlements? plan,
}) {
  final filledCount = cardCount;
  final isPremium = plan?.isPremiumOrHigher ?? false;
  final maxBusinessCards = plan?.limits.maxBusinessCards;
  final canAddCard = maxBusinessCards == null || filledCount < maxBusinessCards;

  if (!isPremium) {
    if (filledCount == 0 && canAddCard) {
      return (unlockedSlots: 1, filledCount: 0);
    }
    return (unlockedSlots: filledCount, filledCount: filledCount);
  }

  if (!canAddCard) {
    return (unlockedSlots: filledCount, filledCount: filledCount);
  }

  const totalSlots = CardIndexCircleSelector.defaultTotalSlots;
  final maxVisibleSlots = maxBusinessCards == null
      ? totalSlots
      : totalSlots.clamp(0, maxBusinessCards);
  final unlockedSlots =
      maxVisibleSlots > filledCount ? maxVisibleSlots : filledCount;
  return (unlockedSlots: unlockedSlots, filledCount: filledCount);
}
