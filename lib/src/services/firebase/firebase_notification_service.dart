import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:txt_invite/src/interfaces/notification_service.dart';
import 'package:txt_invite/src/services/api.dart';

class FirebaseNotificationService implements NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> init() async {
    if (kIsWeb) {
      print('Skipping cloud messaging');
      return;
    }
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    final currentUser = Api().auth.currentUser;
    if (currentUser != null && fcmToken != null) {
      await _firestore.collection('users').doc(currentUser.id).update({
        'fcmToken': fcmToken,
      });
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
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
