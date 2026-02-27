import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate UID
  String generateUID(String phone) {
    final last4 = phone.substring(phone.length - 4);
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    return "ADVN$last4$random";
  }

  /// Create User
  Future<void> createUser({
    required String phone,
    required String adminId,
  }) async {
    final uid = generateUID(phone);

    await _firestore.collection('users').add({
      'uid': uid,
      'phone': phone,
      'name': null,
      'email': null,
      'isFirstLogin': true,
      'membershipActive': false,
      'allocatedPackages': [],
      'createdBy': adminId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all users
  Stream<List<AppUser>> streamUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }
}
