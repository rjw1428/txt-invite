
import 'dart:io';

abstract class StorageService {
  Future<String> uploadFile(File file, String path);
  Future<void> deleteFile(String url);
}
