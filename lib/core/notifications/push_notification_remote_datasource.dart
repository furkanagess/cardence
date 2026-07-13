import 'dart:io';

import '../network/dio_api_client.dart';

abstract class PushNotificationRemoteDataSource {
  Future<void> registerPushToken({
    required String token,
    required String accessToken,
  });

  Future<void> unregisterPushToken({
    required String token,
    required String accessToken,
  });
}

class PushNotificationRemoteDataSourceImpl
    implements PushNotificationRemoteDataSource {
  PushNotificationRemoteDataSourceImpl({DioApiClient? client})
      : _client = client ?? DioApiClient();

  final DioApiClient _client;

  @override
  Future<void> registerPushToken({
    required String token,
    required String accessToken,
  }) {
    return _client.post(
      '/RegisterPushToken',
      body: {
        'token': token,
        'platform': _platformName(),
      },
      accessToken: accessToken,
      fallbackError: 'Push token kaydedilemedi.',
      requireData: false,
    );
  }

  @override
  Future<void> unregisterPushToken({
    required String token,
    required String accessToken,
  }) {
    return _client.delete(
      '/UnregisterPushToken',
      body: {
        'token': token,
        'platform': _platformName(),
      },
      accessToken: accessToken,
      fallbackError: 'Push token silinemedi.',
    );
  }

  String _platformName() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
