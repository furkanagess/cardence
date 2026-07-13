import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> handlePushNotificationBackgroundMessage(RemoteMessage message) async {
  debugPrint(
    '[PushNotification] background message: ${message.messageId} '
    'data=${message.data}',
  );
}
