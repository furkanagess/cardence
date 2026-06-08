/// Sunucuda saklanan iş kartı (domain).
class BusinessCard {
  const BusinessCard({
    this.cardName,
    this.displayName,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.website,
    this.linkedin,
    this.skills,
    this.school,
    this.about,
    this.accentColor,
    this.backgroundColor,
    this.lastUsedPaletteBackgroundColor,
    this.cardId,
  });

  final String? cardName;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? company;
  final String? title;
  final String? website;
  final String? linkedin;
  final String? skills;
  final String? school;
  final String? about;
  final String? accentColor;
  final String? backgroundColor;
  final String? lastUsedPaletteBackgroundColor;
  final String? cardId;
}
