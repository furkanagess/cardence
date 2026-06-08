import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
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

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        phone,
        onboardingCompleted,
        createdAt,
      ];
}
