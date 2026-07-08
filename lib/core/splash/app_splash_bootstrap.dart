import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../app.dart';
import '../init/app_init.dart';
import '../network/interceptors/chuck_interceptor_service.dart';

/// Uygulama açılışı: native splash, platform ayarları ve [AppInit].
class AppSplashBootstrap {
  AppSplashBootstrap._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static void runGuarded() {
    runZonedGuarded(_run, _onZoneError);
  }

  static void _onZoneError(Object error, StackTrace stackTrace) {
    debugPrint('[AppSplashBootstrap] Uncaught zone error: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  static Future<void> _run() async {
    _preserveNativeSplash();
    await _configurePlatform();
    _configureErrorHandling();
    _configureDebugTools();

    try {
      final initResult = await AppInit.init();
      runApp(
        App.withInitResult(
          rootNavigatorKey: rootNavigatorKey,
          init: initResult,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[AppSplashBootstrap] AppInit failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _releaseNativeSplash();
    }
  }

  static void _preserveNativeSplash() {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  static void _releaseNativeSplash() {
    FlutterNativeSplash.remove();
  }

  static Future<void> _configurePlatform() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static void _configureErrorHandling() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[AppSplashBootstrap] FlutterError: ${details.exception}');
    };
  }

  static void _configureDebugTools() {
    ChuckInterceptorService.instance.ensureInitialized(
      navigatorKey: rootNavigatorKey,
    );
  }
}
