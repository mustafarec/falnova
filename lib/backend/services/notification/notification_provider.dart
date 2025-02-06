import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_messaging_service.dart';

final notificationServiceProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});
