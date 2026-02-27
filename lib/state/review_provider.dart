import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewListProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});

final averageRatingProvider = StateProvider<double>((ref) {
  return 0.0;
});

final reviewLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
