import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipPlan {
  final String id;
  final String name;
  final String description;
  final int price;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory MembershipPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MembershipPlan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
    );
  }
}
