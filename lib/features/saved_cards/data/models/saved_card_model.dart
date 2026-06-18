import 'dart:convert';

import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../domain/helpers/saved_card_event_group_link.dart';

class SavedCardModel {
  SavedCardModel({
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
  final String? note;
  final String? photoUrl;
  final String? accentColor;
  final String? backgroundColor;
  final int? savedAt;
  final String? frontImagePath;
  final String? backImagePath;
  final List<String> linkedEventGroupIds;

  factory SavedCardModel.fromEntity(SavedCard entity) {
    return SavedCardModel(
      cardId: entity.cardId,
      origin: entity.origin,
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
      note: entity.note,
      photoUrl: entity.photoUrl,
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      savedAt: entity.savedAt,
      frontImagePath: entity.frontImagePath,
      backImagePath: entity.backImagePath,
      linkedEventGroupIds: List.from(entity.linkedEventGroupIds),
    );
  }

  SavedCard toEntity() => SavedCard(
        cardId: cardId,
        origin: origin,
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
        note: note,
        photoUrl: photoUrl,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        savedAt: savedAt,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
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
        if (note != null) 'note': note,
        'sourceType': SavedCardEventGroupLink.sourceTypeFromOrigin(origin),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (accentColor != null) 'accentColor': accentColor,
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (savedAt != null) 'savedAt': savedAt,
        if (frontImagePath != null) 'frontImagePath': frontImagePath,
        if (backImagePath != null) 'backImagePath': backImagePath,
        if (linkedEventGroupIds.isNotEmpty)
          'linkedEventGroupIds': linkedEventGroupIds,
      };

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      cardId: (json['cardId'] ?? json['CardId']).toString(),
      origin: _parseOrigin(json),
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      website: json['website'] as String?,
      linkedin: json['linkedin'] as String?,
      skills: json['skills'] as String?,
      school: json['school'] as String?,
      about: json['about'] as String? ?? json['About'] as String?,
      note: json['note'] as String? ?? json['Note'] as String?,
      photoUrl: json['photoUrl'] as String?,
      accentColor:
          json['accentColor'] as String? ?? json['AccentColor'] as String?,
      backgroundColor: json['backgroundColor'] as String? ??
          json['BackgroundColor'] as String?,
      savedAt: json['savedAt'] as int?,
      frontImagePath: json['frontImagePath'] as String?,
      backImagePath: json['backImagePath'] as String?,
      linkedEventGroupIds: _parseStringList(json['linkedEventGroupIds']),
    );
  }

  static SavedCardOrigin _parseOrigin(Map<String, dynamic> json) {
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

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) => e as String).toList();
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
