import '../../domain/entities/business_card.dart';

class BusinessCardModel {
  const BusinessCardModel({
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
    this.accentColor,
    this.backgroundColor,
    this.lastUsedPaletteBackgroundColor,
    this.cardId,
  });

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
  final String? accentColor;
  final String? backgroundColor;
  final String? lastUsedPaletteBackgroundColor;
  final String? cardId;

  factory BusinessCardModel.fromEntity(BusinessCard entity) {
    return BusinessCardModel(
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
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      lastUsedPaletteBackgroundColor: entity.lastUsedPaletteBackgroundColor,
      cardId: entity.cardId,
    );
  }

  BusinessCard toEntity() => BusinessCard(
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
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        lastUsedPaletteBackgroundColor: lastUsedPaletteBackgroundColor,
        cardId: cardId,
      );

  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
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
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'lastUsedPaletteBackgroundColor': lastUsedPaletteBackgroundColor,
      'cardId': cardId,
    };
    json.removeWhere((_, value) => value == null);
    return json;
  }

  factory BusinessCardModel.fromJson(Map<String, dynamic> json) {
    return BusinessCardModel(
      cardName: json['cardName']?.toString(),
      displayName: json['displayName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      company: json['company']?.toString(),
      title: json['title']?.toString(),
      website: json['website']?.toString(),
      linkedin: json['linkedin']?.toString(),
      skills: json['skills']?.toString(),
      school: json['school']?.toString(),
      about: json['about']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      accentColor: json['accentColor']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      lastUsedPaletteBackgroundColor:
          json['lastUsedPaletteBackgroundColor']?.toString(),
      cardId: json['cardId']?.toString(),
    );
  }
}
