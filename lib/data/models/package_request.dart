import 'package:cloud_firestore/cloud_firestore.dart';

class PackageRequest {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String packageType;
  final String status;
  final DateTime createdAt;

  PackageRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.packageType,
    required this.status,
    required this.createdAt,
  });

  factory PackageRequest.fromJson(Map<String, dynamic> json, String id) {
    return PackageRequest(
      id: id,
      userId: json['userId'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      packageType: json['packageType'] ?? "",
      status: json['status'] ?? "pending",
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
