import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════
//  USER DOCUMENT MODEL
//  Stores documents uploaded by admin to a specific user's collection.
//  These appear in the user's Documents screen.
//
//  FIX: toJson() wraps createdAt in Timestamp.fromDate() so Firestore
//  doesn't throw [invalid-argument] error.
// ══════════════════════════════════════════════════════════════════════
class UserDocument {
  final String id;
  final String userId;
  final String requestId;
  final String fileUrl;
  final String type;
  final String title;
  final DateTime createdAt;

  UserDocument({
    required this.id,
    required this.userId,
    required this.requestId,
    required this.fileUrl,
    required this.type,
    required this.title,
    required this.createdAt,
  });

  // ── From Firestore ─────────────────────────────────────────────
  factory UserDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDocument(
      id: doc.id,
      userId: data['userId'] ?? '',
      requestId: data['requestId'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      type: data['type'] ?? 'pdf',
      title: data['title'] ?? 'Document',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // ── To Firestore — DateTime wrapped in Timestamp ───────────────
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'requestId': requestId,
    'fileUrl': fileUrl,
    'type': type,
    'title': title,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
