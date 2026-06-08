/// Onboarding ad/soyad ↔ [displayName] dönüşümü.
class OnboardingNameHelper {
  OnboardingNameHelper._();

  /// İlk kelime ad, kalanı soyad.
  static ({String first, String last}) split(String? displayName) {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) return (first: '', last: '');
    final space = trimmed.indexOf(' ');
    if (space < 0) return (first: trimmed, last: '');
    return (
      first: trimmed.substring(0, space).trim(),
      last: trimmed.substring(space + 1).trim(),
    );
  }

  static String combine(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (l.isEmpty) return f;
    if (f.isEmpty) return l;
    return '$f $l';
  }
}
