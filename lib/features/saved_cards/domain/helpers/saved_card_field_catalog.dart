import '../entities/saved_card.dart';

/// Kayıtlı kart detayında gösterilebilen / eklenebilir alan anahtarları.
enum SavedCardFieldKey {
  displayName,
  email,
  phone,
  company,
  title,
  website,
  linkedin,
  school,
  about,
  skills,
  address,
  city,
  country,
  department,
  attendedEvents,
  twitter,
  instagram,
  birthday,
}

/// Alan tanımı ve [SavedCard] üzerinde okuma/yazma.
class SavedCardFieldDefinition {
  const SavedCardFieldDefinition({
    required this.key,
    required this.label,
    required this.iconName,
    required this.hint,
    this.multiline = false,
    this.isLink = false,
    this.editableWhenCardenceLinked = false,
  });

  final SavedCardFieldKey key;
  final String label;
  final String iconName;
  final String hint;
  final bool multiline;
  final bool isLink;

  /// Cardence bağlantılı kartlarda cüzdan sahibi bu alanı düzenleyebilir mi.
  final bool editableWhenCardenceLinked;

  String? readValue(SavedCard card) {
    switch (key) {
      case SavedCardFieldKey.displayName:
        return card.displayName;
      case SavedCardFieldKey.email:
        return card.email;
      case SavedCardFieldKey.phone:
        return card.phone;
      case SavedCardFieldKey.company:
        return card.company;
      case SavedCardFieldKey.title:
        return card.title;
      case SavedCardFieldKey.website:
        return card.website;
      case SavedCardFieldKey.linkedin:
        return card.linkedin;
      case SavedCardFieldKey.school:
        return card.school;
      case SavedCardFieldKey.about:
        return card.about;
      case SavedCardFieldKey.skills:
        return card.skills;
      case SavedCardFieldKey.address:
        return card.address;
      case SavedCardFieldKey.city:
        return card.city;
      case SavedCardFieldKey.country:
        return card.country;
      case SavedCardFieldKey.department:
        return card.department;
      case SavedCardFieldKey.attendedEvents:
        return card.attendedEvents;
      case SavedCardFieldKey.twitter:
        return card.twitter;
      case SavedCardFieldKey.instagram:
        return card.instagram;
      case SavedCardFieldKey.birthday:
        return card.birthday;
    }
  }

  SavedCard writeValue(SavedCard card, String? raw) {
    final value = _normalize(raw);
    switch (key) {
      case SavedCardFieldKey.displayName:
        return card.copyWith(displayName: value, clearDisplayName: raw != null && value == null);
      case SavedCardFieldKey.email:
        return card.copyWith(email: value, clearEmail: raw != null && value == null);
      case SavedCardFieldKey.phone:
        return card.copyWith(phone: value, clearPhone: raw != null && value == null);
      case SavedCardFieldKey.company:
        return card.copyWith(company: value, clearCompany: raw != null && value == null);
      case SavedCardFieldKey.title:
        return card.copyWith(title: value, clearTitle: raw != null && value == null);
      case SavedCardFieldKey.website:
        return card.copyWith(website: value, clearWebsite: raw != null && value == null);
      case SavedCardFieldKey.linkedin:
        return card.copyWith(linkedin: value, clearLinkedin: raw != null && value == null);
      case SavedCardFieldKey.school:
        return card.copyWith(school: value, clearSchool: raw != null && value == null);
      case SavedCardFieldKey.about:
        return card.copyWith(about: value, clearAbout: raw != null && value == null);
      case SavedCardFieldKey.skills:
        return card.copyWith(skills: value, clearSkills: raw != null && value == null);
      case SavedCardFieldKey.address:
        return card.copyWith(address: value, clearAddress: raw != null && value == null);
      case SavedCardFieldKey.city:
        return card.copyWith(city: value, clearCity: raw != null && value == null);
      case SavedCardFieldKey.country:
        return card.copyWith(country: value, clearCountry: raw != null && value == null);
      case SavedCardFieldKey.department:
        return card.copyWith(department: value, clearDepartment: raw != null && value == null);
      case SavedCardFieldKey.attendedEvents:
        return card.copyWith(
          attendedEvents: value,
          clearAttendedEvents: raw != null && value == null,
        );
      case SavedCardFieldKey.twitter:
        return card.copyWith(twitter: value, clearTwitter: raw != null && value == null);
      case SavedCardFieldKey.instagram:
        return card.copyWith(instagram: value, clearInstagram: raw != null && value == null);
      case SavedCardFieldKey.birthday:
        return card.copyWith(birthday: value, clearBirthday: raw != null && value == null);
    }
  }

  bool isEditable(SavedCard card) {
    if (card.isManualEntry) return true;
    return editableWhenCardenceLinked;
  }

  static String? _normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Tüm desteklenen kart alanları kataloğu.
class SavedCardFieldCatalog {
  SavedCardFieldCatalog._();

  static const List<SavedCardFieldDefinition> all = [
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.displayName,
      label: 'Ad Soyad',
      iconName: 'person',
      hint: 'Kişinin adı ve soyadı',
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.email,
      label: 'E-posta',
      iconName: 'email',
      hint: 'ornek@firma.com',
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.phone,
      label: 'Telefon',
      iconName: 'phone',
      hint: '+90 5XX XXX XX XX',
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.company,
      label: 'Şirket',
      iconName: 'apartment',
      hint: 'Çalıştığı şirket',
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.title,
      label: 'Pozisyon',
      iconName: 'work',
      hint: 'Ünvan veya rol',
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.website,
      label: 'Web sitesi',
      iconName: 'language',
      hint: 'https://...',
      isLink: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.linkedin,
      label: 'LinkedIn',
      iconName: 'link',
      hint: 'LinkedIn profil URL',
      isLink: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.address,
      label: 'Adres',
      iconName: 'location',
      hint: 'Açık adres',
      multiline: true,
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.city,
      label: 'Şehir',
      iconName: 'location_city',
      hint: 'İstanbul',
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.country,
      label: 'Ülke',
      iconName: 'public',
      hint: 'Türkiye',
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.department,
      label: 'Departman',
      iconName: 'groups',
      hint: 'Satış, AR-GE vb.',
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.school,
      label: 'Okul',
      iconName: 'school',
      hint: 'Mezun olunan okul',
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.about,
      label: 'Hakkında',
      iconName: 'info',
      hint: 'Kısa tanıtım',
      multiline: true,
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.skills,
      label: 'Yetenekler',
      iconName: 'star',
      hint: 'Virgülle ayırın',
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.attendedEvents,
      label: 'Katıldığı etkinlikler',
      iconName: 'event',
      hint: 'Web Summit 2025, SaaStr Annual…',
      multiline: true,
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.twitter,
      label: 'X (Twitter)',
      iconName: 'alternate_email',
      hint: '@kullanici veya profil URL',
      isLink: true,
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.instagram,
      label: 'Instagram',
      iconName: 'camera',
      hint: '@kullanici veya profil URL',
      isLink: true,
      editableWhenCardenceLinked: true,
    ),
    SavedCardFieldDefinition(
      key: SavedCardFieldKey.birthday,
      label: 'Doğum günü',
      iconName: 'cake',
      hint: '15 Mart veya 15.03.1990',
      editableWhenCardenceLinked: true,
    ),
  ];

  static SavedCardFieldDefinition? byKey(SavedCardFieldKey key) {
    for (final def in all) {
      if (def.key == key) return def;
    }
    return null;
  }

  static bool hasValue(SavedCard card, SavedCardFieldDefinition def) {
    final value = def.readValue(card);
    return value != null && value.trim().isNotEmpty;
  }

  /// Dolu alanlar (gösterim sırası katalog sırası).
  static List<SavedCardFieldDefinition> filledFields(SavedCard card) {
    return all.where((def) => hasValue(card, def)).toList();
  }

  /// Bottom sheet'te eklenebilir alanlar.
  static List<SavedCardFieldDefinition> addableFields(SavedCard card) {
    return all.where((def) {
      if (!def.isEditable(card)) return false;
      return !hasValue(card, def);
    }).toList();
  }
}
