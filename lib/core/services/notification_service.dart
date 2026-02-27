import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fcm.requestPermission();
  }

  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToAdmins() async {
    await _fcm.subscribeToTopic('admins');
  }

  Future<void> subscribeToUsers() async {
    await _fcm.subscribeToTopic('users');
  }

  Future<void> unsubscribeFromAll() async {
    await _fcm.unsubscribeFromTopic('admins');
    await _fcm.unsubscribeFromTopic('users');
  }
}
