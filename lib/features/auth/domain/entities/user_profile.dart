import 'package:equatable/equatable.dart';

import '../../../business_cards/domain/entities/business_card.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    this.displayName,
    this.email,
    this.phone,
    this.onboardingCompleted = false,
    this.createdAt,
    this.savedCards = const [],
    this.businessCards = const [],
  });

  final String userId;
  final String? displayName;
  final String? email;
  final String? phone;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final List<SavedCard> savedCards;
  final List<BusinessCard> businessCards;

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        phone,
        onboardingCompleted,
        createdAt,
        savedCards,
        businessCards,
      ];
}
