import 'package:dio/dio.dart';

import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/auth_session_model.dart';
import '../models/user_profile_model.dart';

export '../../../../core/network/auth_api_exception.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> authenticateWithEmail({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> loginWithPhone({
    required String phone,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  });

  Future<AuthSessionModel> refreshAuthentication(String refreshToken);

  Future<void> forgotPassword({String? email, String? phone});

  Future<AuthSessionModel> resetPassword({
    String? email,
    String? phone,
    String? otpCode,
    String? resetToken,
    required String newPassword,
  });

  Future<AuthSessionModel> loginWithLinkedIn({
    required String authorizationCode,
    required String redirectUri,
  });

  Future<AuthSessionModel> loginWithGoogle({required String idToken});

  Future<AuthSessionModel> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  });

  Future<UserProfileModel> getMe(String accessToken);

  Future<UserProfileModel> completeOnboarding(String accessToken);

  Future<UserProfileModel> uploadProfilePhoto({
    required String filePath,
    required String accessToken,
  });

  Future<void> deleteAccount(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  AuthSessionModel _parseSession(Map<String, dynamic> json) {
    final entity = ApiResponseParser.extractEntity(json);
    if (entity == null) {
      throw AuthApiException('Oturum bilgisi alınamadı.');
    }
    final session = AuthSessionModel.fromJson(entity);
    if (session.accessToken.isEmpty || session.userId.isEmpty) {
      throw AuthApiException('Geçersiz oturum yanıtı.');
    }
    return session;
  }

  UserProfileModel _parseProfile(Map<String, dynamic> json) {
    final entity = ApiResponseParser.readMap(
      json['entity'] ?? json['Entity'] ?? json['data'] ?? json['Data'],
    );
    if (entity == null) {
      throw AuthApiException('Profil bilgisi alınamadı.');
    }
    final profile = UserProfileModel.fromJson(entity);
    if (profile.userId.isEmpty) {
      throw AuthApiException('Geçersiz profil yanıtı.');
    }
    return profile;
  }

  @override
  Future<AuthSessionModel> authenticateWithEmail({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/Authentication',
      body: {
        'email': email,
        'password': password,
        'alreadyTryOtherMethod': false,
      },
      fallbackError: 'İşlem başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<AuthSessionModel> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final json = await _client.post(
      '/LoginWithPhone',
      body: {
        'phone': phone,
        'password': password,
      },
      fallbackError: 'İşlem başarısız.',
    );
    return _parseSession(json);
  }

  // OTP (geçici kapalı):
  // otpCode yoksa requireData: false ile OTP gönderimi

  @override
  Future<AuthSessionModel> loginWithLinkedIn({
    required String authorizationCode,
    required String redirectUri,
  }) async {
    final json = await _client.post(
      '/LoginWithLinkedIn',
      body: {
        'authorizationCode': authorizationCode,
        'redirectUri': redirectUri,
      },
      fallbackError: 'LinkedIn ile giriş başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) async {
    final json = await _client.post(
      '/LoginWithGoogle',
      body: {'idToken': idToken},
      fallbackError: 'Google ile giriş başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<AuthSessionModel> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    final body = <String, dynamic>{
      'identityToken': identityToken,
    };
    if (authorizationCode != null && authorizationCode.isNotEmpty) {
      body['authorizationCode'] = authorizationCode;
    }
    if (givenName != null && givenName.isNotEmpty) {
      body['givenName'] = givenName;
    }
    if (familyName != null && familyName.isNotEmpty) {
      body['familyName'] = familyName;
    }
    final json = await _client.post(
      '/LoginWithApple',
      body: body,
      fallbackError: 'Apple ile giriş başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<AuthSessionModel> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'displayName': displayName,
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    if (phone != null && phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }
    final json = await _client.post(
      '/Register',
      body: body,
      fallbackError: 'İşlem başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<AuthSessionModel> refreshAuthentication(String refreshToken) async {
    final json = await _client.post(
      '/RefreshAuthentication',
      body: {'refreshToken': refreshToken},
      fallbackError: 'İşlem başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<void> forgotPassword({String? email, String? phone}) async {
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    await _client.post(
      '/ForgotPassword',
      body: body,
      fallbackError: 'İşlem başarısız.',
    );
  }

  @override
  Future<AuthSessionModel> resetPassword({
    String? email,
    String? phone,
    String? otpCode,
    String? resetToken,
    required String newPassword,
  }) async {
    final body = <String, dynamic>{
      'newPassword': newPassword,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (otpCode != null && otpCode.isNotEmpty) body['otpCode'] = otpCode;
    if (resetToken != null && resetToken.isNotEmpty) {
      body['resetToken'] = resetToken;
    }
    final json = await _client.post(
      '/ResetPassword',
      body: body,
      fallbackError: 'İşlem başarısız.',
    );
    return _parseSession(json);
  }

  @override
  Future<UserProfileModel> getMe(String accessToken) async {
    final json = await _client.get(
      '/Me',
      accessToken: accessToken,
      fallbackError: 'Profil bilgisi alınamadı.',
    );
    return _parseProfile(json);
  }

  @override
  Future<UserProfileModel> completeOnboarding(String accessToken) async {
    final json = await _client.post(
      '/CompleteOnboarding',
      accessToken: accessToken,
      fallbackError: 'Profil bilgisi alınamadı.',
    );
    return _parseProfile(json);
  }

  @override
  Future<UserProfileModel> uploadProfilePhoto({
    required String filePath,
    required String accessToken,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    final json = await _client.postMultipart(
      '/UploadProfilePhoto',
      formData: formData,
      accessToken: accessToken,
      fallbackError: 'Profil fotoğrafı yüklenemedi.',
    );
    return _parseProfile(json);
  }

  @override
  Future<void> deleteAccount(String accessToken) async {
    await _client.delete(
      '/DeleteAccount',
      accessToken: accessToken,
      fallbackError: 'Hesap silinemedi.',
    );
  }
}
