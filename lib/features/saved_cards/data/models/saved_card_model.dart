import 'dart:convert';

import '../../domain/entities/saved_card.dart';

class SavedCardModel {
  SavedCardModel({
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
  final int? savedAt;
  final List<String> linkedEventGroupIds;

  factory SavedCardModel.fromEntity(SavedCard entity) {
    return SavedCardModel(
      cardId: entity.cardId,
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
      savedAt: entity.savedAt,
      linkedEventGroupIds: List.from(entity.linkedEventGroupIds),
    );
  }

  SavedCard toEntity() => SavedCard(
        cardId: cardId,
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
        savedAt: savedAt,
        linkedEventGroupIds: List.from(linkedEventGroupIds),
      );

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
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
        if (savedAt != null) 'savedAt': savedAt,
        if (linkedEventGroupIds.isNotEmpty)
          'linkedEventGroupIds': linkedEventGroupIds,
      };

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      cardId: json['cardId'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      website: json['website'] as String?,
      linkedin: json['linkedin'] as String?,
      skills: json['skills'] as String?,
      school: json['school'] as String?,
      about: json['about'] as String?,
      savedAt: json['savedAt'] as int?,
      linkedEventGroupIds: _parseStringList(json['linkedEventGroupIds']),
    );
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
