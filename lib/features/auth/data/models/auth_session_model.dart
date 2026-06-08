import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.userId,
    this.refreshToken,
    this.expiresIn = 0,
    this.email,
    this.phone,
    this.displayName,
  });

  final String accessToken;
  final String? refreshToken;
  final String userId;
  final int expiresIn;
  final String? email;
  final String? phone;
  final String? displayName;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken:
          (json['accessToken'] ?? json['AccessToken'])?.toString() ?? '',
      refreshToken:
          (json['refreshToken'] ?? json['RefreshToken'])?.toString(),
      userId: (json['userId'] ?? json['UserId'])?.toString() ?? '',
      expiresIn: ((json['expiresIn'] ?? json['ExpiresIn']) as num?)?.toInt() ??
          0,
      email: (json['email'] ?? json['Email'])?.toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      displayName: (json['displayName'] ?? json['DisplayName'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
        'expiresIn': expiresIn,
        'email': email,
        'phone': phone,
        'displayName': displayName,
      };

  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        expiresIn: expiresIn,
        email: email,
        phone: phone,
        displayName: displayName,
      );

  factory AuthSessionModel.fromEntity(AuthSession entity) => AuthSessionModel(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        userId: entity.userId,
        expiresIn: entity.expiresIn,
        email: entity.email,
        phone: entity.phone,
        displayName: entity.displayName,
      );
}
