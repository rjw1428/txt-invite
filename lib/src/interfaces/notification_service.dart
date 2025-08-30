import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  Future<String?> getDeviceToken(String userId);
  void handleForegroundMessage();
  Future<void> handleBackgroundMessage(RemoteMessage message);
}
