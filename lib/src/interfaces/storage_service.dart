
import 'dart:io';
import 'dart:typed_data';

abstract class StorageService {
  Future<String> uploadFile(File file, String path);
  Future<String> uploadBytes(Uint8List bytes, String path);
  Future<bool> deleteFile(String url);
}
