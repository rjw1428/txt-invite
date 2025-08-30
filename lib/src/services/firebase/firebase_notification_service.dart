import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:txt_invite/src/interfaces/notification_service.dart';

class FirebaseNotificationService implements NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void handleForegroundMessage() {
    if (kIsWeb) {
      print('Skipping cloud messaging');
      return;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  Future<String?> getDeviceToken(String userId) async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  @override
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
