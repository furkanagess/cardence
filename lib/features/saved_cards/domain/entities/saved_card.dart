/// Başka kullanıcıdan QR/ID ile alınıp kaydedilen kart (framework yok).
class SavedCard {
  const SavedCard({
    required this.cardId,
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
    this.savedAt,
    List<String>? linkedEventGroupIds,
  }) : linkedEventGroupIds = linkedEventGroupIds ?? const [];

  final String cardId;
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
  /// Kaydedilme zamanı (ms since epoch).
  final int? savedAt;
  /// Bağlı etkinlik grubu id'leri.
  final List<String> linkedEventGroupIds;

  SavedCard copyWith({
    String? cardId,
    String? displayName,
    String? email,
    String? phone,
    String? company,
    String? title,
    String? website,
    String? linkedin,
    String? skills,
    String? school,
    String? about,
    bool clearAbout = false,
    int? savedAt,
    List<String>? linkedEventGroupIds,
  }) {
    return SavedCard(
      cardId: cardId ?? this.cardId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      title: title ?? this.title,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      skills: skills ?? this.skills,
      school: school ?? this.school,
      about: clearAbout ? null : (about ?? this.about),
      savedAt: savedAt ?? this.savedAt,
      linkedEventGroupIds: linkedEventGroupIds ?? this.linkedEventGroupIds,
    );
  }
}
