import 'saved_card_origin.dart';
import 'card_creation_method.dart';

/// Başka kullanıcıdan ID ile veya manuel olarak kaydedilen kart (framework yok).
class SavedCard {
  const SavedCard({
    required this.cardId,
    this.origin = SavedCardOrigin.cardence,
    this.creationMethod,
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
    this.note,
    this.photoUrl,
    this.accentColor,
    this.backgroundColor,
    this.savedAt,
    this.frontImagePath,
    this.backImagePath,
    this.isOwnerPremium = false,
    List<String>? linkedEventGroupIds,
  }) : linkedEventGroupIds = linkedEventGroupIds ?? const [];

  final String cardId;
  final SavedCardOrigin origin;
  final CardCreationMethod? creationMethod;
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
  final String? note;
  final String? photoUrl;
  final String? accentColor;
  final String? backgroundColor;
  final int? savedAt;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isOwnerPremium;
  final List<String> linkedEventGroupIds;

  bool get isManualEntry =>
      effectiveCreationMethod.isManualEntry;

  bool get isCardenceLinked =>
      effectiveCreationMethod == CardCreationMethod.cardenceLink;

  CardCreationMethod get effectiveCreationMethod {
    if (creationMethod != null) return creationMethod!;
    return origin == SavedCardOrigin.manual
        ? CardCreationMethod.manual
        : CardCreationMethod.cardenceLink;
  }

  SavedCard copyWith({
    String? cardId,
    SavedCardOrigin? origin,
    CardCreationMethod? creationMethod,
    String? displayName,
    bool clearDisplayName = false,
    String? email,
    bool clearEmail = false,
    String? phone,
    bool clearPhone = false,
    String? company,
    bool clearCompany = false,
    String? title,
    bool clearTitle = false,
    String? website,
    bool clearWebsite = false,
    String? linkedin,
    bool clearLinkedin = false,
    String? skills,
    bool clearSkills = false,
    String? school,
    bool clearSchool = false,
    String? about,
    bool clearAbout = false,
    String? address,
    bool clearAddress = false,
    String? city,
    bool clearCity = false,
    String? country,
    bool clearCountry = false,
    String? department,
    bool clearDepartment = false,
    String? attendedEvents,
    bool clearAttendedEvents = false,
    String? twitter,
    bool clearTwitter = false,
    String? instagram,
    bool clearInstagram = false,
    String? birthday,
    bool clearBirthday = false,
    String? note,
    bool clearNote = false,
    String? photoUrl,
    String? accentColor,
    String? backgroundColor,
    int? savedAt,
    String? frontImagePath,
    String? backImagePath,
    bool? isOwnerPremium,
    List<String>? linkedEventGroupIds,
  }) {
    return SavedCard(
      cardId: cardId ?? this.cardId,
      origin: origin ?? this.origin,
      creationMethod: creationMethod ?? this.creationMethod,
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      company: clearCompany ? null : (company ?? this.company),
      title: clearTitle ? null : (title ?? this.title),
      website: clearWebsite ? null : (website ?? this.website),
      linkedin: clearLinkedin ? null : (linkedin ?? this.linkedin),
      skills: clearSkills ? null : (skills ?? this.skills),
      school: clearSchool ? null : (school ?? this.school),
      about: clearAbout ? null : (about ?? this.about),
      address: clearAddress ? null : (address ?? this.address),
      city: clearCity ? null : (city ?? this.city),
      country: clearCountry ? null : (country ?? this.country),
      department: clearDepartment ? null : (department ?? this.department),
      attendedEvents:
          clearAttendedEvents ? null : (attendedEvents ?? this.attendedEvents),
      twitter: clearTwitter ? null : (twitter ?? this.twitter),
      instagram: clearInstagram ? null : (instagram ?? this.instagram),
      birthday: clearBirthday ? null : (birthday ?? this.birthday),
      note: clearNote ? null : (note ?? this.note),
      photoUrl: photoUrl ?? this.photoUrl,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      savedAt: savedAt ?? this.savedAt,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      isOwnerPremium: isOwnerPremium ?? this.isOwnerPremium,
      linkedEventGroupIds: linkedEventGroupIds ?? this.linkedEventGroupIds,
    );
  }
}
