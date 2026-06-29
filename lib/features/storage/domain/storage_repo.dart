import 'dart:typed_data';

abstract class StorageRepo {
  //upload profile from mobile
  Future<String?> uploadProfileImageMobile(String path, String filename);

  //upload profile pic from web
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String filename);

  //upload post from mobile
  Future<String?> uploadPostImageMobile(String path, String filename);

  //upload post pic from web
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String filename);
}
