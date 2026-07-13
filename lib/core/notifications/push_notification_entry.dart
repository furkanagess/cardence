import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_notification_background.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await handlePushNotificationBackgroundMessage(message);
}
