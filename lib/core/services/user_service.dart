import 'package:admin_app/core/services/auth_service.dart';
import 'package:admin_app/core/services/firestore_service.dart';
import 'package:admin_app/data/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final AuthService _auth = AuthService.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  // ==========================================================
  // 🚀 REGISTER USER
  // ==========================================================

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // 1️⃣ Create Firebase Auth user
      final firebaseUser = await _auth.signUpWithEmail(
        email.trim(),
        password.trim(),
      );

      final uid = firebaseUser.uid;

      // 2️⃣ Generate Custom UID
      final customUid =
          "USR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // 3️⃣ Create AppUser model
      final appUser = AppUser(
        id: uid,
        firebaseUid: uid,
        customUid: customUid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: "user",
        membershipActive: false,
        isFirstLogin: true,
        membershipId: null,
        membershipName: null,
        expiryDate: null,
        allocatedPackages: [],
        immunities: {},
        phone: phone,
        profileImage: null,

        // 🔥 NEW FIELD
        totalHolidays: 0,

        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.createUser(appUser);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    } catch (e) {
      throw Exception("Something went wrong. Try again.");
    }
  }

  // ==========================================================
  // 👤 GET CURRENT APP USER
  // ==========================================================

  Future<AppUser?> getCurrentAppUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    return await _firestore.getUser(uid);
  }

  // ==========================================================
  // 🔄 ENSURE USER DOCUMENT EXISTS
  // ==========================================================

  Future<void> ensureUserDocumentExists() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    final existing = await _firestore.getUser(firebaseUser.uid);

    if (existing == null) {
      final customUid =
          "USR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      final newUser = AppUser(
        id: firebaseUser.uid,
        firebaseUid: firebaseUser.uid,
        customUid: customUid,
        name: firebaseUser.displayName ?? "User",
        email: firebaseUser.email ?? "",
        role: "user",
        membershipActive: false,
        isFirstLogin: true,
        membershipId: null,
        membershipName: null,
        expiryDate: null,
        allocatedPackages: [],
        immunities: {},
        phone: firebaseUser.phoneNumber,
        profileImage: firebaseUser.photoURL,

        // 🔥 IMPORTANT
        totalHolidays: 0,

        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.createUser(newUser);
    }
  }

  // ==========================================================
  // ✏ UPDATE USER PROFILE
  // ==========================================================

  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.updateUser(uid, {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'isFirstLogin': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // 🔢 UPDATE TOTAL HOLIDAYS (Optional Helper)
  // ==========================================================

  Future<void> updateTotalHolidays(int total) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.updateUser(uid, {
      'totalHolidays': total,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
