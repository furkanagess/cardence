import 'saved_card_origin.dart';

/// Başka kullanıcıdan ID ile veya manuel olarak kaydedilen kart (framework yok).
class SavedCard {
  const SavedCard({
    required this.cardId,
    this.origin = SavedCardOrigin.cardence,
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
    this.note,
    this.photoUrl,
    this.accentColor,
    this.backgroundColor,
    this.savedAt,
    this.frontImagePath,
    this.backImagePath,
    List<String>? linkedEventGroupIds,
  }) : linkedEventGroupIds = linkedEventGroupIds ?? const [];

  final String cardId;
  final SavedCardOrigin origin;
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
  /// Kaydeden kullanıcının kişisel notu (kart sahibinin Hakkımda alanı değil).
  final String? note;
  final String? photoUrl;
  /// Kart metin rengi (hex, örn. #FFFFFF).
  final String? accentColor;
  /// Kart arka plan rengi (hex, örn. #1B365D).
  final String? backgroundColor;
  /// Kaydedilme zamanı (ms since epoch).
  final int? savedAt;
  /// Yerel fiziksel kartvizit ön yüz fotoğrafı (yalnızca cihazda).
  final String? frontImagePath;
  /// Yerel fiziksel kartvizit arka yüz fotoğrafı (yalnızca cihazda).
  final String? backImagePath;
  /// Bağlı etkinlik grubu id'leri.
  final List<String> linkedEventGroupIds;

  bool get isManualEntry => origin == SavedCardOrigin.manual;

  bool get isCardenceLinked => origin == SavedCardOrigin.cardence;

  SavedCard copyWith({
    String? cardId,
    SavedCardOrigin? origin,
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
    String? note,
    bool clearNote = false,
    String? photoUrl,
    String? accentColor,
    String? backgroundColor,
    int? savedAt,
    String? frontImagePath,
    String? backImagePath,
    List<String>? linkedEventGroupIds,
  }) {
    return SavedCard(
      cardId: cardId ?? this.cardId,
      origin: origin ?? this.origin,
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
      note: clearNote ? null : (note ?? this.note),
      photoUrl: photoUrl ?? this.photoUrl,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      savedAt: savedAt ?? this.savedAt,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      linkedEventGroupIds: linkedEventGroupIds ?? this.linkedEventGroupIds,
    );
  }
}
