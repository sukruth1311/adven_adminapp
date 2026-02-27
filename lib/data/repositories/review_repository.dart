import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<void> createReview({
    required String hotelId,
    required String userId,
    required String comment,
    required double rating,
  }) async {
    try {
      await _firestore.collection('reviews').add({
        'hotelId': hotelId,
        'userId': userId,
        'comment': comment,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getReviewsByHotel(String hotelId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('hotelId', isEqualTo: hotelId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getAverageRating(String hotelId) async {
    try {
      final reviews = await getReviewsByHotel(hotelId);
      if (reviews.isEmpty) return 0.0;
      final sum = reviews.fold<double>(
        0,
        (acc, review) => acc + (review['rating'] as num).toDouble(),
      );
      return sum / reviews.length;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
