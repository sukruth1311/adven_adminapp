import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserDocument({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('user_documents/$userId/$fileName');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
