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
    this.address,
    this.city,
    this.country,
    this.department,
    this.attendedEvents,
    this.twitter,
    this.instagram,
    this.birthday,
    this.photoUrl,
    this.accentColor,
    this.backgroundColor,
    this.cardEffect,
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
  final String? address;
  final String? city;
  final String? country;
  final String? department;
  final String? attendedEvents;
  final String? twitter;
  final String? instagram;
  final String? birthday;
  final String? photoUrl;
  final String? accentColor;
  final String? backgroundColor;
  final String? cardEffect;
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
      address: entity.address,
      city: entity.city,
      country: entity.country,
      department: entity.department,
      attendedEvents: entity.attendedEvents,
      twitter: entity.twitter,
      instagram: entity.instagram,
      birthday: entity.birthday,
      photoUrl: entity.photoUrl,
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      cardEffect: entity.cardEffect,
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
        address: address,
        city: city,
        country: country,
        department: department,
        attendedEvents: attendedEvents,
        twitter: twitter,
        instagram: instagram,
        birthday: birthday,
        photoUrl: photoUrl,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        cardEffect: cardEffect,
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
      'address': address,
      'city': city,
      'country': country,
      'department': department,
      'attendedEvents': attendedEvents,
      'twitter': twitter,
      'instagram': instagram,
      'birthday': birthday,
      'photoUrl': photoUrl,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'cardEffect': cardEffect,
      'cardId': cardId,
    };
    json.removeWhere((_, value) => value == null);
    return json;
  }

  static String? _str(dynamic value) =>
      value == null ? null : value.toString();

  factory BusinessCardModel.fromJson(Map<String, dynamic> json) {
    return BusinessCardModel(
      cardName: _str(json['cardName'] ?? json['CardName']),
      displayName: _str(json['displayName'] ?? json['DisplayName']),
      email: _str(json['email'] ?? json['Email']),
      phone: _str(json['phone'] ?? json['Phone']),
      company: _str(json['company'] ?? json['Company']),
      title: _str(json['title'] ?? json['Title']),
      website: _str(json['website'] ?? json['Website']),
      linkedin: _str(json['linkedin'] ?? json['Linkedin']),
      skills: _str(json['skills'] ?? json['Skills']),
      school: _str(json['school'] ?? json['School']),
      about: _str(json['about'] ?? json['About']),
      address: _str(json['address'] ?? json['Address']),
      city: _str(json['city'] ?? json['City']),
      country: _str(json['country'] ?? json['Country']),
      department: _str(json['department'] ?? json['Department']),
      attendedEvents: _str(json['attendedEvents'] ?? json['AttendedEvents']),
      twitter: _str(json['twitter'] ?? json['Twitter']),
      instagram: _str(json['instagram'] ?? json['Instagram']),
      birthday: _str(json['birthday'] ?? json['Birthday']),
      photoUrl: _str(json['photoUrl'] ?? json['PhotoUrl']),
      accentColor: _str(json['accentColor'] ?? json['AccentColor']),
      backgroundColor: _str(json['backgroundColor'] ?? json['BackgroundColor']),
      cardEffect: _str(json['cardEffect'] ?? json['CardEffect']),
      cardId: _str(json['cardId'] ?? json['CardId']),
    );
  }
}
