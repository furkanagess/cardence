import 'dart:convert';

import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/entities/card_creation_method.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../domain/helpers/saved_card_event_group_link.dart';

class SavedCardModel {
  SavedCardModel({
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

  factory SavedCardModel.fromEntity(SavedCard entity) {
    return SavedCardModel(
      cardId: entity.cardId,
      origin: entity.origin,
      creationMethod: entity.creationMethod,
      displayName: entity.displayName,
      email: entity.email,
      phone: entity.phone,
      company: entity.company,
      title: entity.title,
      website: entity.website,
      linkedin: entity.linkedin,
      skills: entity.skills,
      school: entity.school,
      about: entity.about,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      department: entity.department,
      attendedEvents: entity.attendedEvents,
      twitter: entity.twitter,
      instagram: entity.instagram,
      birthday: entity.birthday,
      note: entity.note,
      photoUrl: entity.photoUrl,
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      savedAt: entity.savedAt,
      frontImagePath: entity.frontImagePath,
      backImagePath: entity.backImagePath,
      isOwnerPremium: entity.isOwnerPremium,
      linkedEventGroupIds: List.from(entity.linkedEventGroupIds),
    );
  }

  SavedCard toEntity() => SavedCard(
        cardId: cardId,
        origin: origin,
        creationMethod: creationMethod,
        displayName: displayName,
        email: email,
        phone: phone,
        company: company,
        title: title,
        website: website,
        linkedin: linkedin,
        skills: skills,
        school: school,
        about: about,
        address: address,
        city: city,
        country: country,
        department: department,
        attendedEvents: attendedEvents,
        twitter: twitter,
        instagram: instagram,
        birthday: birthday,
        note: note,
        photoUrl: photoUrl,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        savedAt: savedAt,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        isOwnerPremium: isOwnerPremium,
        linkedEventGroupIds: List.from(linkedEventGroupIds),
      );

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'origin': origin.name,
        if (displayName != null) 'displayName': displayName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (company != null) 'company': company,
        if (title != null) 'title': title,
        if (website != null) 'website': website,
        if (linkedin != null) 'linkedin': linkedin,
        if (skills != null) 'skills': skills,
        if (school != null) 'school': school,
        if (about != null) 'about': about,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (department != null) 'department': department,
        if (attendedEvents != null) 'attendedEvents': attendedEvents,
        if (twitter != null) 'twitter': twitter,
        if (instagram != null) 'instagram': instagram,
        if (birthday != null) 'birthday': birthday,
        if (note != null) 'note': note,
        'sourceType': SavedCardEventGroupLink.sourceTypeFromOrigin(origin),
        if (creationMethod != null) 'creationMethod': creationMethod!.apiValue,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (accentColor != null) 'accentColor': accentColor,
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (savedAt != null) 'savedAt': savedAt,
        if (frontImagePath != null) 'frontImagePath': frontImagePath,
        if (backImagePath != null) 'backImagePath': backImagePath,
        'isOwnerPremium': isOwnerPremium,
        if (linkedEventGroupIds.isNotEmpty)
          'linkedEventGroupIds': linkedEventGroupIds,
      };

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      cardId: (json['cardId'] ?? json['CardId']).toString(),
      origin: _parseOrigin(json),
      creationMethod: _parseCreationMethod(json),
      displayName: _str(json, 'displayName', 'DisplayName'),
      email: _str(json, 'email'),
      phone: _str(json, 'phone'),
      company: _str(json, 'company'),
      title: _str(json, 'title'),
      website: _str(json, 'website'),
      linkedin: _str(json, 'linkedin'),
      skills: _str(json, 'skills'),
      school: _str(json, 'school'),
      about: _str(json, 'about', 'About'),
      address: _str(json, 'address', 'Address'),
      city: _str(json, 'city', 'City'),
      country: _str(json, 'country', 'Country'),
      department: _str(json, 'department', 'Department'),
      attendedEvents: _str(json, 'attendedEvents', 'AttendedEvents'),
      twitter: _str(json, 'twitter', 'Twitter'),
      instagram: _str(json, 'instagram', 'Instagram'),
      birthday: _str(json, 'birthday', 'Birthday'),
      note: _str(json, 'note', 'Note'),
      photoUrl: _str(json, 'photoUrl'),
      accentColor: _str(json, 'accentColor', 'AccentColor'),
      backgroundColor: _str(json, 'backgroundColor', 'BackgroundColor'),
      savedAt: json['savedAt'] as int?,
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      isOwnerPremium: _parseBool(
        json['isOwnerPremium'] ?? json['IsOwnerPremium'],
      ),
      linkedEventGroupIds: _parseStringList(json['linkedEventGroupIds']),
    );
  }

  static String? _str(Map<String, dynamic> json, String key, [String? alt]) {
    return json[key] as String? ?? (alt != null ? json[alt] as String? : null);
  }

  static SavedCardOrigin _parseOrigin(Map<String, dynamic> json) {
    final creationMethod = _parseCreationMethod(json);
    if (creationMethod != null) {
      return creationMethod.isManualEntry
          ? SavedCardOrigin.manual
          : SavedCardOrigin.cardence;
    }

    final sourceType = json['sourceType'] as String? ?? json['SourceType'] as String?;
    if (sourceType != null) {
      return SavedCardEventGroupLink.originFromSourceType(sourceType);
    }

    final raw = json['origin'] as String?;
    if (raw == SavedCardOrigin.manual.name) {
      return SavedCardOrigin.manual;
    }
    if (raw == SavedCardOrigin.cardence.name) {
      return SavedCardOrigin.cardence;
    }
    if (json['frontImagePath'] != null || json['backImagePath'] != null) {
      return SavedCardOrigin.manual;
    }
    final cardId = (json['cardId'] ?? json['CardId'])?.toString();
    if (CardIdGenerator.isManualWalletId(cardId)) {
      return SavedCardOrigin.manual;
    }
    return SavedCardOrigin.cardence;
  }

  static CardCreationMethod? _parseCreationMethod(Map<String, dynamic> json) {
    final raw = json['creationMethod'] as String? ?? json['CreationMethod'] as String?;
    final parsed = CardCreationMethod.fromApi(raw);
    if (parsed != null) return parsed;

    if (json['frontImagePath'] != null || json['backImagePath'] != null) {
      return CardCreationMethod.photoScan;
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) => e as String).toList();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static List<SavedCardModel> listFromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => SavedCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJsonString(List<SavedCardModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }
}
