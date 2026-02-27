import 'package:cloud_firestore/cloud_firestore.dart';

class OfferRepository {
  final FirebaseFirestore _firestore;

  OfferRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<void> createOffer({
    required String hotelId,
    required String title,
    required String description,
    required double discount,
  }) async {
    try {
      await _firestore.collection('offers').add({
        'hotelId': hotelId,
        'title': title,
        'description': description,
        'discount': discount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOffersByHotel(String hotelId) async {
    try {
      final querySnapshot = await _firestore
          .collection('offers')
          .where('hotelId', isEqualTo: hotelId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
