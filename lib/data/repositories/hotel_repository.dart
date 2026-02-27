import 'package:cloud_firestore/cloud_firestore.dart';

class HotelRepository {
  final FirebaseFirestore _firestore;

  HotelRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<void> createHotel({
    required String name,
    required String location,
    required String description,
    required double rating,
  }) async {
    try {
      await _firestore.collection('hotels').add({
        'name': name,
        'location': location,
        'description': description,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllHotels() async {
    try {
      final querySnapshot = await _firestore.collection('hotels').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHotel(String hotelId) async {
    try {
      final doc = await _firestore.collection('hotels').doc(hotelId).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHotel(String hotelId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHotel(String hotelId) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
