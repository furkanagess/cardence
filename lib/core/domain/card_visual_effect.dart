/// Kart yüzeyinde gösterilebilecek görsel efektler (framework bağımsız).
enum CardVisualEffect {
  none,
  stars,
  sparkle,
  shimmer,
  neon,
  glow,
  aurora,
  pulse,
  holographic,
  rain,
  snow,
  fire,
  confetti,
  cosmic,
  ripple,
  diamond,
  sunset,
  frost,
  matrix;

  static const List<CardVisualEffect> selectable = [
    none,
    confetti,
    pulse,
    neon,
    sparkle,
    stars,
    shimmer,
    glow,
    aurora,
    holographic,
    rain,
    snow,
    fire,
    cosmic,
    ripple,
    diamond,
    sunset,
    frost,
    matrix,
  ];

  bool get requiresPremium => this != none;

  /// Pro olmayan kullanıcıda efekt gösterilmez / seçilemez.
  static CardVisualEffect forViewer(
    CardVisualEffect effect, {
    required bool isPremium,
  }) {
    if (effect == none || isPremium) return effect;
    return none;
  }

  String get storageKey {
    switch (this) {
      case CardVisualEffect.none:
        return 'none';
      case CardVisualEffect.stars:
        return 'stars';
      case CardVisualEffect.sparkle:
        return 'sparkle';
      case CardVisualEffect.shimmer:
        return 'shimmer';
      case CardVisualEffect.neon:
        return 'neon';
      case CardVisualEffect.glow:
        return 'glow';
      case CardVisualEffect.aurora:
        return 'aurora';
      case CardVisualEffect.pulse:
        return 'pulse';
      case CardVisualEffect.holographic:
        return 'holographic';
      case CardVisualEffect.rain:
        return 'rain';
      case CardVisualEffect.snow:
        return 'snow';
      case CardVisualEffect.fire:
        return 'fire';
      case CardVisualEffect.confetti:
        return 'confetti';
      case CardVisualEffect.cosmic:
        return 'cosmic';
      case CardVisualEffect.ripple:
        return 'ripple';
      case CardVisualEffect.diamond:
        return 'diamond';
      case CardVisualEffect.sunset:
        return 'sunset';
      case CardVisualEffect.frost:
        return 'frost';
      case CardVisualEffect.matrix:
        return 'matrix';
    }
  }

  static CardVisualEffect fromStorage(String? value) {
    if (value == null || value.isEmpty) return none;
    for (final effect in selectable) {
      if (effect.storageKey == value) return effect;
    }
    return none;
  }
}
