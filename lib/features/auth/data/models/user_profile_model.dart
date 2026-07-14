import '../../../business_cards/data/models/business_card_model.dart';
import '../../../saved_cards/data/models/saved_card_model.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    this.displayName,
    this.email,
    this.phone,
    this.photoUrl,
    this.onboardingCompleted = false,
    this.isPremium = false,
    this.isOwnerPremium = false,
    this.createdAt,
    this.savedCardIds = const [],
    this.savedCards = const [],
    this.businessCards = const [],
  });

  final String userId;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final bool onboardingCompleted;
  final bool isPremium;
  final bool isOwnerPremium;
  final DateTime? createdAt;
  final List<String> savedCardIds;
  final List<SavedCardModel> savedCards;
  final List<BusinessCardModel> businessCards;

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return false;
  }

  static List<SavedCardModel> _parseSavedCards(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SavedCardModel.fromJson)
        .toList();
  }

  static List<String> _parseSavedCardIds(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<BusinessCardModel> _parseBusinessCards(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(BusinessCardModel.fromJson)
        .toList();
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['createdAt'] as String? ?? json['CreatedAt'] as String?;
    return UserProfileModel(
      userId: (json['userId'] ?? json['UserId'])?.toString() ?? '',
      displayName:
          (json['displayName'] ?? json['DisplayName'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      photoUrl: (json['photoUrl'] ?? json['PhotoUrl'])?.toString(),
      onboardingCompleted: _readBool(
        json['onboardingCompleted'] ?? json['OnboardingCompleted'],
      ),
      isPremium: _readBool(json['premium'] ?? json['Premium']),
      isOwnerPremium: _readBool(
        json['isOwnerPremium'] ??
            json['IsOwnerPremium'] ??
            json['premium'] ??
            json['Premium'],
      ),
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      savedCardIds: _parseSavedCardIds(
        json['savedCardIds'] ?? json['SavedCardIds'],
      ),
      savedCards: _parseSavedCards(json['savedCards'] ?? json['SavedCards']),
      businessCards:
          _parseBusinessCards(json['businessCards'] ?? json['BusinessCards']),
    );
  }

  UserProfile toEntity() => UserProfile(
        userId: userId,
        displayName: displayName,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        onboardingCompleted: onboardingCompleted,
        isPremium: isPremium,
        isOwnerPremium: isOwnerPremium,
        createdAt: createdAt,
        savedCardIds: savedCardIds.isNotEmpty
            ? savedCardIds
            : savedCards.map((card) => card.cardId).toList(),
        savedCards: savedCards.map((card) => card.toEntity()).toList(),
        businessCards: businessCards.map((card) => card.toEntity()).toList(),
      );

  /// Ayarlar / offline geri dönüş için hafif profil önbelleği.
  Map<String, dynamic> toCacheJson() => {
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'onboardingCompleted': onboardingCompleted,
        'premium': isPremium,
        'isOwnerPremium': isOwnerPremium,
      };
}
