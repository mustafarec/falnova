import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  Future<void> checkFirebaseStatus() async {
    try {
      debugPrint('Firebase Durumu Kontrolü Başladı');

      // FCM token'ı kontrol et
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $token');

      // Bildirim izinlerini kontrol et
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint('Bildirim İzinleri: ${settings.authorizationStatus}');

      // Firebase bağlantısını kontrol et
      final isSupported = await FirebaseMessaging.instance.isSupported();
      debugPrint('Firebase Destekleniyor: $isSupported');

      // Ön plan bildirim ayarlarını kontrol et
      final foregroundSettings =
          await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint('Ön Plan Bildirim Ayarları: ${foregroundSettings.alert}');

      debugPrint('Firebase Durumu Kontrolü Tamamlandı');
    } catch (e) {
      debugPrint('Firebase Durumu Kontrolünde Hata: $e');
    }
  }
}
