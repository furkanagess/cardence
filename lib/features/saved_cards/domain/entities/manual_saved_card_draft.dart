import 'saved_card.dart';
import 'saved_card_origin.dart';

/// Elle veya OCR ile oluşturulan kayıtlı kart taslağı.
class ManualSavedCardDraft {
  const ManualSavedCardDraft({
    this.displayName,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.website,
    this.linkedin,
    this.about,
    this.frontImagePath,
    this.backImagePath,
  });

  final String? displayName;
  final String? email;
  final String? phone;
  final String? company;
  final String? title;
  final String? website;
  final String? linkedin;
  final String? about;
  final String? frontImagePath;
  final String? backImagePath;

  bool get hasContactInfo {
    return _has(displayName) || _has(email) || _has(phone);
  }

  ManualSavedCardDraft copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? company,
    String? title,
    String? website,
    String? linkedin,
    String? about,
    String? frontImagePath,
    String? backImagePath,
  }) {
    return ManualSavedCardDraft(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      title: title ?? this.title,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      about: about ?? this.about,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
    );
  }

  SavedCard toSavedCard({
    required String cardId,
    required int savedAt,
  }) {
    return SavedCard(
      cardId: cardId,
      origin: SavedCardOrigin.manual,
      displayName: _trimOrNull(displayName),
      email: _trimOrNull(email),
      phone: _trimOrNull(phone),
      company: _trimOrNull(company),
      title: _trimOrNull(title),
      website: _trimOrNull(website),
      linkedin: _trimOrNull(linkedin),
      about: _trimOrNull(about),
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      savedAt: savedAt,
    );
  }

  static bool _has(String? value) => value != null && value.trim().isNotEmpty;

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
