import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    this.refreshToken,
    this.expiresIn = 0,
    this.accessTokenExpiresAt,
    this.email,
    this.phone,
    this.displayName,
  });

  final String accessToken;
  final String? refreshToken;
  final String userId;
  final int expiresIn;
  final int? accessTokenExpiresAt;
  final String? email;
  final String? phone;
  final String? displayName;

  bool get isValid =>
      userId.isNotEmpty &&
      (accessToken.isNotEmpty || (refreshToken?.isNotEmpty ?? false));

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        userId,
        expiresIn,
        accessTokenExpiresAt,
        email,
        phone,
        displayName,
      ];
}
