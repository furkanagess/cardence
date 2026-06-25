enum PlanTier {
  free,
  premium,
  business,
  enterprise;

  static PlanTier fromName(String value) {
    return PlanTier.values.firstWhere(
      (tier) => tier.name == value.trim().toLowerCase(),
      orElse: () => PlanTier.free,
    );
  }
}
