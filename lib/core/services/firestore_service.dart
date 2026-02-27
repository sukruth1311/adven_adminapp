import 'package:admin_app/data/models/app_user.dart';
import 'package:admin_app/data/models/document_file.dart';
import 'package:admin_app/data/models/hotel_request.dart';
import 'package:admin_app/data/models/membership.dart';
import 'package:admin_app/data/models/membership_plan.dart';
import 'package:admin_app/data/models/membership_request.dart';
import 'package:admin_app/data/models/offer.dart';
import 'package:admin_app/data/models/package_request.dart';
import 'package:admin_app/data/models/review.dart';
import 'package:admin_app/data/models/user_document.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================================
  // 👤 USERS
  // ==========================================================

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (!doc.exists || doc.data() == null) return null;

    return AppUser.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<AppUser?> streamUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return AppUser.fromFirestore(doc);
        });
  }

  Future<void> updateImmunities(
    String userId,
    Map<String, bool> immunities,
  ) async {
    await _db.collection('users').doc(userId).update({
      'immunities': immunities,
    });
  }

  Future<void> updateMembershipStatus(String userId, bool isMember) async {
    await _db.collection('users').doc(userId).update({'isMember': isMember});
  }

  Future<void> createAdminUser({
    required String firebaseUid,
    required String customUid,
    required String name,
    required String phone,
    required String email,
    required String role,
  }) async {
    await _db.collection("users").doc(firebaseUid).set({
      "customUid": customUid,
      "name": name,
      "phone": phone,
      "email": email,
      "role": role,
      "membershipApproved": false,
      "membershipPackage": null,
      "expiryDate": null,
      "immunities": {},
      "usageLimits": {},
      "createdByAdmin": true,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> createServiceRequest({required String destination}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('service_requests').add({
      'userId': uid, // IMPORTANT
      'destination': destination,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamUserServiceRequests(String userId) {
    return FirebaseFirestore.instance
        .collection('service_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<List<QueryDocumentSnapshot>> streamAllUserRequests(String userId) {
    return FirebaseFirestore.instance
        .collection('service_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<QueryDocumentSnapshot>> streamPendingRequests() {
    return FirebaseFirestore.instance
        .collection('service_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // ==========================================================
  // 💳 MEMBERSHIP PLANS
  // ==========================================================

  Stream<List<MembershipPlan>> streamMembershipPlans() {
    return _db.collection('membership_plans').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MembershipPlan.fromFirestore(doc))
          .toList();
    });
  }

  // ==========================================================
  // 📩 MEMBERSHIP REQUESTS
  // ==========================================================

  Future<void> allocateMembership({
    required String userId, // Firestore document ID
    required String membershipName,
    required String membershipId,
    required DateTime expiryDate,
    required Map<String, bool> immunities,
    String? requestId,
    String? packageRequestId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final userRef = firestore.collection('users').doc(userId);

    // 🔥 Update USER document
    await userRef.update({
      'membershipActive': true,
      'membershipId': membershipId,
      'membershipName': membershipName,
      'expiryDate': expiryDate,
      'immunities': immunities,
      'isFirstLogin': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 🔥 Only update request if it exists
    if (requestId != null && requestId != "manual_allocation") {
      await firestore.collection('membership_requests').doc(requestId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (packageRequestId != null) {
      await firestore
          .collection('package_requests')
          .doc(packageRequestId)
          .update({
            'status': 'approved',
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }
  }

  Stream<List<MembershipRequest>> streamUserPendingMembershipRequests(
    String userId,
  ) {
    return _db
        .collection('membership_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MembershipRequest.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> createMembershipRequest(MembershipRequest request) async {
    await _db
        .collection('membership_requests')
        .doc(request.id)
        .set(request.toJson());
  }

  Stream<List<MembershipRequest>> streamMembershipRequests() {
    return _db
        .collection('membership_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MembershipRequest.fromJson(doc.data()))
              .toList();
        });
  }

  Stream<List<MembershipRequest>> streamUserMembershipRequests(String userId) {
    return _db
        .collection('membership_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MembershipRequest.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> approveMembership({
    required String userId,
    required String requestId,
    required String membershipId,
    required Map<String, bool> immunities,
  }) async {
    await _db.collection('users').doc(userId).update({
      'isMember': true,
      'membershipId': membershipId,
      'immunities': immunities,
    });

    await _db.collection('membership_requests').doc(requestId).update({
      'status': 'approved',
    });
  }

  // ==========================================================
  // 🏨 HOTEL REQUESTS
  // ==========================================================

  Future<void> createHotelRequest(HotelRequest request) async {
    await _db
        .collection('hotel_requests')
        .doc(request.id)
        .set(request.toJson());
  }

  Future<void> updateHotelRequestStatus(String id, String status) async {
    await _db.collection("hotel_requests").doc(id).update({"status": status});
  }

  Stream<List<HotelRequest>> streamAllHotelRequests() {
    return _db
        .collection('hotel_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HotelRequest.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<HotelRequest>> streamUserHotelRequests(String uid) {
    return _db
        .collection('hotel_requests')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HotelRequest.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> uploadHotelConfirmation({
    required String userId,
    required String hotelRequestId,
    required File file,
  }) async {
    final ref = _storage.ref().child(
      'hotel_documents/$userId/$hotelRequestId.pdf',
    );

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await _db.collection('user_documents').add({
      'userId': userId,
      'requestId': hotelRequestId,
      'fileUrl': url,
      'type': 'hotel',
      'title': 'Hotel Confirmation',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("🔥 Firestore document created for user: $userId");
  }

  Stream<List<Map<String, dynamic>>> streamUserHotelDocuments(String userId) {
    return _db
        .collection('hotel_documents')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }

  // ==========================================================
  // 📄 USER DOCUMENTS (Hotel Confirmation, Insurance, etc.)
  // ==========================================================

  Future<void> createUserDocument({
    required String name,
    required String email,
    required String phone,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('users').doc(uid).set({
      'firebaseUid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserMembership({
    required String userId,
    required String membershipName,
    required String membershipId,
    required DateTime expiryDate,
    required Map<String, bool> immunities,
  }) async {
    await _db.collection('users').doc(userId).update({
      'isMember': true,
      'membershipName': membershipName,
      'membershipId': membershipId,
      'expiryDate': expiryDate.toIso8601String(),
      'immunities': immunities,
    });
  }

  Future<void> cancelMembership(String userId) async {
    await _db.collection('users').doc(userId).update({
      'isMember': false,
      'membershipName': null,
      'membershipId': null,
      'expiryDate': null,
      'immunities': {},
    });
  }

  Stream<List<UserDocument>> streamUserDocuments() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('user_documents')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserDocument.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> deleteUserDocument(String documentId) async {
    await _db.collection('user_documents').doc(documentId).delete();
  }

  Future<void> uploadUserDocument({
    required String userId,
    required String requestId,
    required String type,
    required String title,
    required File file,
  }) async {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.pdf";

    final ref = _storage.ref().child('user_documents/$userId/$fileName');

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await _db.collection('user_documents').add({
      'userId': userId, // MUST be Firebase UID
      'requestId': requestId,
      'fileUrl': url,
      'type': type,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // 📄 PUBLIC DOCUMENTS
  // ==========================================================
  Stream<int> streamPendingRequestCount(String userDocId) {
    return FirebaseFirestore.instance
        .collection('service_requests')
        .where('userId', isEqualTo: userDocId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> uploadDocument(DocumentFile document) async {
    await _db.collection('documents').doc(document.id).set(document.toJson());
  }

  Stream<List<DocumentFile>> streamPublicDocuments() {
    return _db
        .collection('documents')
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DocumentFile.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> deleteDocument(String documentId) async {
    await _db.collection('documents').doc(documentId).delete();
  }

  // ==========================================================
  // 👥 ADMIN - STREAM ALL USERS
  // ==========================================================

  Stream<List<AppUser>> streamAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  // ==========================================================
  // ⭐ REVIEWS
  // ==========================================================

  Future<void> createReview(Review review) async {
    await _db.collection('reviews').doc(review.id).set(review.toJson());
  }

  Stream<List<Review>> streamPendingReviews() {
    return _db
        .collection('reviews')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Review.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> approveReview(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).update({'isApproved': true});
  }

  // ==========================================================
  // 🎁 OFFERS
  // ==========================================================

  Future<void> createOffer(Offer offer) async {
    await _db.collection('offers').doc(offer.id).set(offer.toJson());
  }

  Stream<List<Offer>> streamActiveOffers() {
    return _db
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Offer.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> deactivateOffer(String offerId) async {
    await _db.collection('offers').doc(offerId).update({'isActive': false});
  }

  // ==========================================================
  // 🏷 MEMBERSHIP DETAILS (Optional Separate Collection)
  // ==========================================================

  Future<void> createMembership(Membership membership) async {
    await _db
        .collection('memberships')
        .doc(membership.id)
        .set(membership.toJson());
  }

  Future<Membership?> getMembership(String userId) async {
    final query = await _db
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return Membership.fromJson(query.docs.first.data());
  }

  //========================================================= packages ===============
  Future<void> createPackageRequest(Map<String, dynamic> data) async {
    await _db.collection('package_requests').doc(data["id"]).set(data);
  }

  Future<void> approvePackageRequest(String requestId) async {
    await _db.collection('package_requests').doc(requestId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectPackageRequest(String requestId) async {
    await _db.collection('package_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  Stream<List<PackageRequest>> streamPackageRequests() {
    return _db
        .collection('package_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PackageRequest.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> updatePackageRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await _db.collection('package_requests').doc(requestId).update({
      'status': status,
    });
  }
}
