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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] as String?;
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
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
