import 'package:cloud_firestore/cloud_firestore.dart';

class HotelRequest {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String location;
  final bool isInternational;
  final int nights;
  final int members;
  final String travelMode;
  final String specialRequest;
  final String status;
  final DateTime createdAt;

  HotelRequest({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.location,
    required this.isInternational,
    required this.nights,
    required this.members,
    required this.travelMode,
    required this.specialRequest,
    required this.status,
    required this.createdAt,
  });

  /// ✅ Proper Firestore factory
  factory HotelRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HotelRequest(
      id: doc.id,
      userId: data["userId"] ?? "",
      checkIn: (data["checkIn"] as Timestamp).toDate(),
      checkOut: (data["checkOut"] as Timestamp).toDate(),
      location: data["location"] ?? "",
      isInternational: data["isInternational"] ?? false,
      nights: data["nights"] ?? 0,
      members: data["members"] ?? 0,
      travelMode: data["travelMode"] ?? "",
      specialRequest: data["specialRequest"] ?? "",
      status: data["status"] ?? "pending",
      createdAt: (data["createdAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "checkIn": checkIn,
    "checkOut": checkOut,
    "location": location,
    "isInternational": isInternational,
    "nights": nights,
    "members": members,
    "travelMode": travelMode,
    "specialRequest": specialRequest,
    "status": status,
    "createdAt": createdAt,
  };
}
