import 'dart:convert';

import '../../domain/entities/onboarding_card_draft.dart';

/// Kart taslağı modeli – JSON / entity dönüşümü Data katmanında.
class OnboardingCardDraftModel {
  OnboardingCardDraftModel({
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
    this.photoUrl,
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
  final String? photoUrl;
  final List<String> visibleFields;
  final List<String> frontVisibleFields;
  final List<String> backVisibleFields;
  final String? accentColor;
  final String? backgroundColor;
  final String? lastUsedPaletteBackgroundColor;
  final List<String> linkedEventGroupIds;
  final String? cardId;

  factory OnboardingCardDraftModel.fromEntity(OnboardingCardDraft entity) {
    final front = List<String>.from(entity.frontVisibleFields);
    final back = List<String>.from(entity.backVisibleFields);
    final union = <String>{...front, ...back}.toList();
    return OnboardingCardDraftModel(
      cardName: entity.cardName,
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
      photoUrl: entity.photoUrl,
      visibleFields: union,
      frontVisibleFields: front,
      backVisibleFields: back,
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      lastUsedPaletteBackgroundColor: entity.lastUsedPaletteBackgroundColor,
      linkedEventGroupIds: List.from(entity.linkedEventGroupIds),
      cardId: entity.cardId,
    );
  }

  OnboardingCardDraft toEntity() {
    return OnboardingCardDraft(
      cardName: cardName,
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
      photoUrl: photoUrl,
      visibleFields: List.from(visibleFields),
      frontVisibleFields: List.from(frontVisibleFields),
      backVisibleFields: List.from(backVisibleFields),
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      lastUsedPaletteBackgroundColor: lastUsedPaletteBackgroundColor,
      linkedEventGroupIds: List.from(linkedEventGroupIds),
      cardId: cardId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardName': cardName,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'company': company,
      'title': title,
      'website': website,
      'linkedin': linkedin,
      'skills': skills,
      'school': school,
      'about': about,
      'photoUrl': photoUrl,
      'visibleFields': visibleFields,
      'frontVisibleFields': frontVisibleFields,
      'backVisibleFields': backVisibleFields,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'lastUsedPaletteBackgroundColor': lastUsedPaletteBackgroundColor,
      'linkedEventGroupIds': linkedEventGroupIds,
      'cardId': cardId,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) => e as String).toList();
  }

  factory OnboardingCardDraftModel.fromJson(Map<String, dynamic> json) {
    final visibleFields = (json['visibleFields'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    var front = _parseStringList(json['frontVisibleFields']);
    var back = _parseStringList(json['backVisibleFields']);
    if (front.isEmpty && back.isEmpty && visibleFields.isNotEmpty) {
      front = visibleFields
          .where((k) => OnboardingCardDraft.frontFieldKeys.contains(k))
          .take(3)
          .toList();
      back = visibleFields
          .where((k) => OnboardingCardDraft.backFieldKeys.contains(k))
          .take(3)
          .toList();
    }
    if (front.isEmpty) {
      front = List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields);
    }
    return OnboardingCardDraftModel(
      cardName: json['cardName'] as String?,
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
      photoUrl: json['photoUrl'] as String?,
      visibleFields: visibleFields,
      frontVisibleFields: front,
      backVisibleFields: back,
      accentColor: json['accentColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      lastUsedPaletteBackgroundColor:
          json['lastUsedPaletteBackgroundColor'] as String?,
      linkedEventGroupIds: (json['linkedEventGroupIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      cardId: json['cardId'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static OnboardingCardDraftModel? fromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return OnboardingCardDraftModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
