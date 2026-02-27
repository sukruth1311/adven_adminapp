import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════
//  HOTEL REQUEST MODEL — includes all merged holiday fields.
//
//  IMPORTANT: toJson() uses Timestamp.fromDate() for ALL DateTime fields.
//  Passing raw Dart DateTime to Firestore causes [invalid-argument] error.
// ══════════════════════════════════════════════════════════════════════
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

  // ── Holiday-specific fields (merged from HolidayServiceScreen) ─
  final String subDestination;
  final String memberName;
  final int totalDays;
  final int adults;
  final int kids;
  final DateTime? travelDate;
  final String? aadharUrl;

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
    this.subDestination = '',
    this.memberName = '',
    this.totalDays = 0,
    this.adults = 1,
    this.kids = 0,
    this.travelDate,
    this.aadharUrl,
  });

  // ── From Firestore ─────────────────────────────────────────────
  factory HotelRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safe Timestamp → DateTime helper
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();

    return HotelRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      checkIn: ts(data['checkIn']),
      checkOut: ts(data['checkOut']),
      location: data['location'] ?? '',
      isInternational: data['isInternational'] ?? false,
      nights: data['nights'] ?? 0,
      members: data['members'] ?? 0,
      travelMode: data['travelMode'] ?? '',
      specialRequest: data['specialRequest'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: ts(data['createdAt']),
      subDestination: data['subDestination'] ?? '',
      memberName: data['memberName'] ?? '',
      totalDays: data['totalDays'] ?? 0,
      adults: data['adults'] ?? 1,
      kids: data['kids'] ?? 0,
      travelDate: data['travelDate'] != null ? ts(data['travelDate']) : null,
      aadharUrl: data['aadharUrl'],
    );
  }

  // ── To Firestore — ALL DateTimes wrapped in Timestamp ──────────
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'checkIn': Timestamp.fromDate(checkIn),
    'checkOut': Timestamp.fromDate(checkOut),
    'location': location,
    'isInternational': isInternational,
    'nights': nights,
    'members': members,
    'travelMode': travelMode,
    'specialRequest': specialRequest,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'subDestination': subDestination,
    'memberName': memberName,
    'totalDays': totalDays,
    'adults': adults,
    'kids': kids,
    'travelDate': travelDate != null ? Timestamp.fromDate(travelDate!) : null,
    'aadharUrl': aadharUrl,
  };
}
