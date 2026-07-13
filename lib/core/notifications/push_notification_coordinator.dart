import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../auth/auth_token_provider.dart';
import 'push_notification_entry.dart';
import 'push_notification_remote_datasource.dart';
import 'push_notification_types.dart';

typedef PushNotificationTapHandler = void Function(Map<String, dynamic> data);

class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required AuthTokenProvider authTokens,
    PushNotificationRemoteDataSource? remote,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _authTokens = authTokens,
        _remote = remote ?? PushNotificationRemoteDataSourceImpl(),
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  static PushNotificationCoordinator? instance;

  static const _androidChannelId = 'cardence_default';
  static const _androidChannelName = 'Cardence Bildirimleri';

  final AuthTokenProvider _authTokens;
  final PushNotificationRemoteDataSource _remote;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _currentToken;
  PushNotificationTapHandler? onNotificationTap;

  Future<void> initialize() async {
    instance = this;
    await _configureLocalNotifications();
    await _requestPermissions();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    _tokenRefreshSubscription =
        _messaging.onTokenRefresh.listen(_onTokenRefresh);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  Future<void> syncTokenForCurrentSession() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      final accessToken = await _authTokens.tryAccessToken();
      if (accessToken == null || accessToken.isEmpty) return;

      _currentToken = token;
      await _remote.registerPushToken(
        token: token,
        accessToken: accessToken,
      );
    } catch (error, stackTrace) {
      debugPrint('[PushNotification] token sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> unregisterCurrentToken() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final accessToken = await _authTokens.tryAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        await _remote.unregisterPushToken(
          token: token,
          accessToken: accessToken,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('[PushNotification] token unregister failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _currentToken = null;
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    if (identical(instance, this)) {
      instance = null;
    }
  }

  Future<void> _configureLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        onNotificationTap?.call(_decodePayload(payload));
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    _currentToken = token;
    await syncTokenForCurrentSession();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: _encodePayload(message.data),
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    onNotificationTap?.call(message.data);
  }

  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }

  Map<String, dynamic> _decodePayload(String payload) {
    final result = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final separatorIndex = part.indexOf('=');
      if (separatorIndex <= 0) continue;
      result[part.substring(0, separatorIndex)] =
          part.substring(separatorIndex + 1);
    }
    return result;
  }
}

String? readPushNotificationType(Map<String, dynamic> data) {
  final type = data['type'];
  if (type is String && type.isNotEmpty) return type;
  return null;
}

bool isEventGroupInviteNotification(Map<String, dynamic> data) {
  return readPushNotificationType(data) == PushNotificationTypes.eventGroupInvite;
}

bool isCardSavedNotification(Map<String, dynamic> data) {
  return readPushNotificationType(data) == PushNotificationTypes.cardSaved;
}
