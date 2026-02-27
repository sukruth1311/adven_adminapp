import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// 🔥 Firestore factory
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

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'requestId': requestId,
      'fileUrl': fileUrl,
      'type': type,
      'title': title,
      'createdAt': createdAt,
    };
  }
}
