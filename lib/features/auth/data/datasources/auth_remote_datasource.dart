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
    required String otpCode,
    required String newPassword,
  });

  Future<UserProfileModel> getMe(String accessToken);

  Future<UserProfileModel> completeOnboarding(String accessToken);
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

  @override
  Future<AuthSessionModel> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'displayName': displayName,
      'email': email,
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
    required String otpCode,
    required String newPassword,
  }) async {
    final body = <String, dynamic>{
      'otpCode': otpCode,
      'newPassword': newPassword,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
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
}
