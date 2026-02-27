import 'package:flutter_riverpod/flutter_riverpod.dart';

final hotelListProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});

final selectedHotelProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

final hotelLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
