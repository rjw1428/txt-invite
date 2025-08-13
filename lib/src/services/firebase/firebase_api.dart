
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:txt_invite/src/interfaces/messaging_service.dart';
import 'package:txt_invite/src/interfaces/storage_service.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/guest.dart';

class FirebaseApi
    implements
        StorageService,
        MessagingService {
  final FirebaseStorage _storage;

  static Future<FirebaseApi> initialize() async {
    await Firebase.initializeApp();
    return FirebaseApi._internal();
  }

  FirebaseApi._internal()
      : _storage = FirebaseStorage.instance;


  @override
  Future<void> deleteFile(String url) async {
    await _storage.refFromURL(url).delete();
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> sendMessage(Guest contact, String message) async {
    final uri = Uri(scheme: 'sms', path: contact.phoneNumber, queryParameters: {'body': message});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
  

}