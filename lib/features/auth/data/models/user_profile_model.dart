import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    this.displayName,
    this.email,
    this.phone,
    this.onboardingCompleted = false,
    this.createdAt,
  });

  final String userId;
  final String? displayName;
  final String? email;
  final String? phone;
  final bool onboardingCompleted;
  final DateTime? createdAt;

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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['createdAt'] as String? ?? json['CreatedAt'] as String?;
    return UserProfileModel(
      userId: (json['userId'] ?? json['UserId'])?.toString() ?? '',
      displayName:
          (json['displayName'] ?? json['DisplayName'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      onboardingCompleted: _readBool(
        json['onboardingCompleted'] ?? json['OnboardingCompleted'],
      ),
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
    );
  }

  UserProfile toEntity() => UserProfile(
        userId: userId,
        displayName: displayName,
        email: email,
        phone: phone,
        onboardingCompleted: onboardingCompleted,
        createdAt: createdAt,
      );
}
