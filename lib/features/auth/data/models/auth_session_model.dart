import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.userId,
    this.refreshToken,
    this.expiresIn = 0,
    this.accessTokenExpiresAt,
    this.email,
    this.phone,
    this.displayName,
  });

  static const _expirySkewMs = 60 * 1000;

  final String accessToken;
  final String? refreshToken;
  final String userId;
  final int expiresIn;
  final int? accessTokenExpiresAt;
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
      accessTokenExpiresAt:
          (json['accessTokenExpiresAt'] as num?)?.toInt(),
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
        if (accessTokenExpiresAt != null)
          'accessTokenExpiresAt': accessTokenExpiresAt,
        'email': email,
        'phone': phone,
        'displayName': displayName,
      };

  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        expiresIn: expiresIn,
        accessTokenExpiresAt: accessTokenExpiresAt,
        email: email,
        phone: phone,
        displayName: displayName,
      );

  factory AuthSessionModel.fromEntity(AuthSession entity) => AuthSessionModel(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        userId: entity.userId,
        expiresIn: entity.expiresIn,
        accessTokenExpiresAt: entity.accessTokenExpiresAt,
        email: entity.email,
        phone: entity.phone,
        displayName: entity.displayName,
      );

  bool get isAccessTokenStale {
    if (accessToken.isEmpty) return true;
    if (accessTokenExpiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= accessTokenExpiresAt! - _expirySkewMs;
  }

  bool get canRestoreSession =>
      userId.isNotEmpty &&
      (accessToken.isNotEmpty || (refreshToken?.isNotEmpty ?? false));

  AuthSessionModel withComputedExpiry() {
    if (expiresIn <= 0) return this;
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      expiresIn: expiresIn,
      accessTokenExpiresAt: expiresAt,
      email: email,
      phone: phone,
      displayName: displayName,
    );
  }
}
