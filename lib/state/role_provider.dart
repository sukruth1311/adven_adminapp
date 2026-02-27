import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔐 Checks Firebase Custom Claims for admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return false;

  final token = await user.getIdTokenResult(true);

  return token.claims?['admin'] == true;
});
