import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:txt_invite/src/interfaces/storage_service.dart';

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path) async {
    try {
      final Uint8List fileBytes = await file.readAsBytes();
      return uploadBytes(fileBytes, path);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(bytes);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading bytes: $e');
      rethrow;
    }
  }
  
  
  @override
  Future<bool> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
