import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> handleBackgroundMessage(RemoteMessage message);
}
