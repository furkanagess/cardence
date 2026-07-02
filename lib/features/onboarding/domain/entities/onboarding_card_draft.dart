import '../../../../core/domain/card_visual_effect.dart';

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
    this.address,
    this.city,
    this.country,
    this.department,
    this.attendedEvents,
    this.twitter,
    this.instagram,
    this.birthday,
    this.photoUrl,
    List<String>? visibleFields,
    List<String>? frontVisibleFields,
    List<String>? backVisibleFields,
    this.accentColor,
    this.backgroundColor,
    this.lastUsedPaletteBackgroundColor,
    this.cardEffect = CardVisualEffect.none,
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
  final String? address;
  final String? city;
  final String? country;
  final String? department;
  final String? attendedEvents;
  final String? twitter;
  final String? instagram;
  final String? birthday;
  final String? photoUrl;
  final List<String> visibleFields;

  /// Ön yüzde gösterilecek alanlar (en fazla 3).
  final List<String> frontVisibleFields;

  /// Arka yüzde gösterilecek alanlar (en fazla 3).
  final List<String> backVisibleFields;
  final String? accentColor;
  final String? backgroundColor;
  final String? lastUsedPaletteBackgroundColor;
  final CardVisualEffect cardEffect;
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

  /// Ön yüz alt iletişim satırları için varsayılan (e-posta + telefon).
  static const List<String> defaultFrontVisibleFields = [
    'email',
    'phone',
  ];

  /// Eski varsayılan ön yüz (geçiş için).
  static const List<String> legacyDefaultFrontVisibleFields = [
    'company',
    'title',
    'email',
  ];

  /// Ön yüz alt kısımda seçilebilir iletişim alanları.
  static const List<String> cardFrontContactFieldKeys = [
    'email',
    'phone',
    'linkedin',
    'website',
  ];

  /// Ön yüz için seçilebilir alan anahtarları (ayarlar UI).
  static const List<String> frontFieldKeys = cardFrontContactFieldKeys;

  /// Arka yüzde varsayılan: yalnızca Hakkımda.
  static const List<String> defaultBackVisibleFields = ['about'];

  /// Arka yüz için seçilebilir ek alan anahtarları (Hakkımda her zaman gösterilir).
  static const List<String> backFieldKeys = [
    'skills',
  ];

  /// Ön yüz alt iletişim satırları; boş veya eski formatta varsayılan kullanılır.
  List<String> get resolvedFrontContactFields {
    final contactOnly = frontVisibleFields
        .where((k) => cardFrontContactFieldKeys.contains(k))
        .toList();
    if (contactOnly.isNotEmpty) return contactOnly;
    if (frontVisibleFields.isEmpty ||
        _listEquals(frontVisibleFields, legacyDefaultFrontVisibleFields)) {
      return List<String>.from(defaultFrontVisibleFields);
    }
    return List<String>.from(defaultFrontVisibleFields);
  }

  /// Geriye dönük uyumluluk.
  List<String> get resolvedFrontVisibleFields => resolvedFrontContactFields;

  bool get shouldMigrateFrontFields =>
      frontVisibleFields.isEmpty ||
      _listEquals(frontVisibleFields, legacyDefaultFrontVisibleFields);

  /// Ön yüz iletişim alanlarını güncel varsayılana taşır.
  OnboardingCardDraft withStandardFrontFields() {
    if (!shouldMigrateFrontFields) return this;
    return copyWith(
      frontVisibleFields: List<String>.from(defaultFrontVisibleFields),
    );
  }

  /// Arka yüzde yetenekler gösterilsin mi.
  bool get showSkillsOnBack => backVisibleFields.contains('skills');

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Form ve tasarım alanlarının tamamını karşılaştırır (kaydedilmemiş değişiklik tespiti).
  bool contentEquals(OnboardingCardDraft other) {
    return cardName == other.cardName &&
        displayName == other.displayName &&
        email == other.email &&
        phone == other.phone &&
        company == other.company &&
        title == other.title &&
        website == other.website &&
        linkedin == other.linkedin &&
        skills == other.skills &&
        school == other.school &&
        about == other.about &&
        address == other.address &&
        city == other.city &&
        country == other.country &&
        department == other.department &&
        attendedEvents == other.attendedEvents &&
        twitter == other.twitter &&
        instagram == other.instagram &&
        birthday == other.birthday &&
        photoUrl == other.photoUrl &&
        accentColor == other.accentColor &&
        backgroundColor == other.backgroundColor &&
        lastUsedPaletteBackgroundColor ==
            other.lastUsedPaletteBackgroundColor &&
        cardEffect == other.cardEffect &&
        cardId == other.cardId &&
        _listEquals(visibleFields, other.visibleFields) &&
        _listEquals(frontVisibleFields, other.frontVisibleFields) &&
        _listEquals(backVisibleFields, other.backVisibleFields) &&
        _listEquals(linkedEventGroupIds, other.linkedEventGroupIds);
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
    String? address,
    String? city,
    String? country,
    String? department,
    String? attendedEvents,
    String? twitter,
    String? instagram,
    String? birthday,
    String? photoUrl,
    bool clearPhotoUrl = false,
    List<String>? visibleFields,
    List<String>? frontVisibleFields,
    List<String>? backVisibleFields,
    String? accentColor,
    bool clearAccentColor = false,
    String? backgroundColor,
    bool clearBackgroundColor = false,
    String? lastUsedPaletteBackgroundColor,
    CardVisualEffect? cardEffect,
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
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      department: department ?? this.department,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      birthday: birthday ?? this.birthday,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      visibleFields: visibleFields ?? this.visibleFields,
      frontVisibleFields: frontVisibleFields ?? this.frontVisibleFields,
      backVisibleFields: backVisibleFields ?? this.backVisibleFields,
      accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
      backgroundColor: clearBackgroundColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      lastUsedPaletteBackgroundColor:
          lastUsedPaletteBackgroundColor ?? this.lastUsedPaletteBackgroundColor,
      cardEffect: cardEffect ?? this.cardEffect,
      linkedEventGroupIds: linkedEventGroupIds ?? this.linkedEventGroupIds,
      cardId: cardId ?? this.cardId,
    );
  }
}
