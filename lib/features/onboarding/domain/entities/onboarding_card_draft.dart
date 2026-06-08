/// Onboarding sırasında toplanan kart taslağı (domain entity – framework yok).
/// [backgroundColor] kart arka plan rengi (hex).
/// [accentColor] kart üzerindeki metin rengi (hex); null ise arka plana göre otomatik kontrast.
/// [linkedEventGroupIds] yalnızca geriye dönük uyumluluk; kendi kartlar etkinlik
/// gruplarına bağlanmaz ve kayıtta her zaman boş tutulur.
class OnboardingCardDraft {
  const OnboardingCardDraft({
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
    List<String>? visibleFields,
    List<String>? frontVisibleFields,
    List<String>? backVisibleFields,
    this.accentColor,
    this.backgroundColor,
    this.lastUsedPaletteBackgroundColor,
    List<String>? linkedEventGroupIds,
    this.cardId,
  })  : visibleFields = visibleFields ?? const [],
        frontVisibleFields = frontVisibleFields ?? const [],
        backVisibleFields = backVisibleFields ?? const [],
        linkedEventGroupIds = linkedEventGroupIds ?? const [];

  /// Kullanıcının verdiği kart etiketi (liste ve detay başlığı).
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
  final List<String> visibleFields;
  /// Ön yüzde gösterilecek alanlar (en fazla 3).
  final List<String> frontVisibleFields;
  /// Arka yüzde gösterilecek alanlar (en fazla 3).
  final List<String> backVisibleFields;
  final String? accentColor;
  final String? backgroundColor;
  final String? lastUsedPaletteBackgroundColor;
  final List<String> linkedEventGroupIds;
  /// QR / paylaşım için benzersiz kart id; yoksa oluşturulur.
  final String? cardId;

  /// Liste ve başlıkta gösterilecek ad.
  String get listTitle {
    final name = cardName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final display = displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    return 'İsimsiz kart';
  }

  /// Liste alt satırı.
  String? get listSubtitle {
    final org = company?.trim();
    if (org != null && org.isNotEmpty) return org;
    final role = title?.trim();
    if (role != null && role.isNotEmpty) return role;
    return null;
  }

  static const List<String> availableFields = [
    'displayName',
    'email',
    'phone',
    'company',
    'title',
    'website',
    'linkedin',
    'skills',
    'school',
    'about',
  ];

  /// Ön yüzde varsayılan gösterilecek alanlar (şirket, pozisyon, e-posta).
  static const List<String> defaultFrontVisibleFields = [
    'company',
    'title',
    'email',
  ];

  /// Eski varsayılan ön yüz (geçiş için).
  static const List<String> legacyDefaultFrontVisibleFields = [
    'company',
    'title',
    'email',
  ];

  /// Ön yüz için seçilebilir alan anahtarları.
  static const List<String> frontFieldKeys = [
    'title',
    'email',
    'phone',
    'company',
    'skills',
    'school',
    'about',
  ];
  /// Arka yüz için seçilebilir alan anahtarları.
  static const List<String> backFieldKeys = [
    'email', 'phone', 'website', 'linkedin',
  ];

  /// Ön yüzde gösterilecek alanlar; boş veya eski varsayılanda [defaultFrontVisibleFields].
  List<String> get resolvedFrontVisibleFields {
    if (frontVisibleFields.isEmpty) {
      return defaultFrontVisibleFields;
    }
    if (frontVisibleFields.length == legacyDefaultFrontVisibleFields.length &&
        _listEquals(frontVisibleFields, legacyDefaultFrontVisibleFields)) {
      return defaultFrontVisibleFields;
    }
    return frontVisibleFields;
  }

  bool get shouldMigrateFrontFields =>
      frontVisibleFields.isEmpty ||
      (frontVisibleFields.length == legacyDefaultFrontVisibleFields.length &&
          _listEquals(frontVisibleFields, legacyDefaultFrontVisibleFields));

  /// Ön yüzü ünvan + e-posta + telefon varsayılanına günceller.
  OnboardingCardDraft withStandardFrontFields() {
    if (!shouldMigrateFrontFields) return this;
    return copyWith(
      frontVisibleFields: List<String>.from(defaultFrontVisibleFields),
    );
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  OnboardingCardDraft copyWith({
    String? cardName,
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
    List<String>? visibleFields,
    List<String>? frontVisibleFields,
    List<String>? backVisibleFields,
    String? accentColor,
    bool clearAccentColor = false,
    String? backgroundColor,
    bool clearBackgroundColor = false,
    String? lastUsedPaletteBackgroundColor,
    List<String>? linkedEventGroupIds,
    String? cardId,
  }) {
    return OnboardingCardDraft(
      cardName: cardName ?? this.cardName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      title: title ?? this.title,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      skills: skills ?? this.skills,
      school: school ?? this.school,
      about: about ?? this.about,
      visibleFields: visibleFields ?? this.visibleFields,
      frontVisibleFields: frontVisibleFields ?? this.frontVisibleFields,
      backVisibleFields: backVisibleFields ?? this.backVisibleFields,
      accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
      backgroundColor: clearBackgroundColor ? null : (backgroundColor ?? this.backgroundColor),
      lastUsedPaletteBackgroundColor: lastUsedPaletteBackgroundColor ?? this.lastUsedPaletteBackgroundColor,
      linkedEventGroupIds: linkedEventGroupIds ?? this.linkedEventGroupIds,
      cardId: cardId ?? this.cardId,
    );
  }
}
