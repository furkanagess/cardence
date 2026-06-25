class PlanLimits {
  const PlanLimits({
    this.maxBusinessCards,
    this.maxSavedCards,
    this.maxEventGroups,
    this.maxTeamSeats = 1,
  });

  /// Ücretsiz planda kayıtlı kart üst sınırı.
  static const int defaultFreeSavedCardsLimit = 15;

  final int? maxBusinessCards;
  final int? maxSavedCards;
  final int? maxEventGroups;
  final int maxTeamSeats;

  bool get hasUnlimitedBusinessCards => maxBusinessCards == null;

  bool get hasUnlimitedSavedCards => maxSavedCards == null;

  bool get hasUnlimitedEventGroups => maxEventGroups == null;
}
