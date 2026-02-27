import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;

  final String? firebaseUid;
  final String? customUid;
  final int? totalHolidays;
  final String name;
  final String email;
  final String role;

  final bool membershipActive;
  final bool isFirstLogin;

  final String? membershipId;
  final String? membershipName;
  final DateTime? expiryDate;

  final List<dynamic> allocatedPackages;
  final Map<String, bool> immunities;

  final String? phone;
  final String? profileImage;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    this.firebaseUid,
    this.customUid,
    required this.name,
    required this.email,
    required this.role,
    required this.totalHolidays,
    required this.membershipActive,
    required this.isFirstLogin,
    this.membershipId,
    this.membershipName,
    this.expiryDate,
    this.allocatedPackages = const [],
    this.immunities = const {},
    this.phone,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ FROM FIRESTORE
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("User document is empty");
    }

    return AppUser(
      id: doc.id,

      firebaseUid: data['firebaseUid'],
      customUid: data['customUid'],

      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',

      membershipActive: data['membershipActive'] ?? false,
      isFirstLogin: data['isFirstLogin'] ?? false,

      membershipId: data['membershipId'],
      membershipName: data['membershipName'],

      expiryDate: data['expiryDate'] is Timestamp
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,

      allocatedPackages: List<dynamic>.from(data['allocatedPackages'] ?? []),

      immunities: data['immunities'] != null
          ? Map<String, bool>.from(
              (data['immunities'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, value == true),
              ),
            )
          : {},
      totalHolidays: data['totalHolidays'] ?? 0,
      phone: data['phone'],
      profileImage: data['profileImage'],

      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,

      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ✅ TO FIRESTORE
  Map<String, dynamic> toJson() {
    return {
      'firebaseUid': firebaseUid,
      'customUid': customUid,
      'name': name,
      'email': email,
      'role': role,
      'membershipActive': membershipActive,
      'isFirstLogin': isFirstLogin,
      'membershipId': membershipId,
      'membershipName': membershipName,
      'totalHolidays': totalHolidays,
      'expiryDate': expiryDate,
      'allocatedPackages': allocatedPackages,
      'immunities': immunities,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ COPY WITH
  AppUser copyWith({
    String? name,
    String? email,
    bool? membershipActive,
    bool? isFirstLogin,
    String? membershipId,
    String? membershipName,
    DateTime? expiryDate,
    List<dynamic>? allocatedPackages,
    Map<String, bool>? immunities,
  }) {
    return AppUser(
      id: id,
      firebaseUid: firebaseUid,
      customUid: customUid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      membershipActive: membershipActive ?? this.membershipActive,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      membershipId: membershipId ?? this.membershipId,
      totalHolidays: totalHolidays ?? this.totalHolidays,
      membershipName: membershipName ?? this.membershipName,
      expiryDate: expiryDate ?? this.expiryDate,
      allocatedPackages: allocatedPackages ?? this.allocatedPackages,
      immunities: immunities ?? this.immunities,
      phone: phone,
      profileImage: profileImage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
