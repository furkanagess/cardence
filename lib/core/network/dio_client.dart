import 'package:dio/dio.dart';

import 'interceptors/chuck_interceptor_service.dart';

/// Uygulama genelinde paylaşılan Dio istemcisi.
class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance => _instance ??= _create();

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final chuckInterceptor = ChuckInterceptorService.instance.dioInterceptor;
    if (chuckInterceptor != null) {
      dio.interceptors.add(chuckInterceptor);
    }

    return dio;
  }

  static void reset() {
    _instance?.close(force: true);
    _instance = null;
  }
}
