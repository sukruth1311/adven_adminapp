import 'package:flutter_riverpod/flutter_riverpod.dart';

final offerListProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});

final selectedOfferProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

final offerLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
