import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Arka planda bildirim alındı: ${message.messageId}');
  debugPrint('Bildirim başlığı: ${message.notification?.title}');
  debugPrint('Bildirim içeriği: ${message.notification?.body}');
  debugPrint('Bildirim data: ${message.data}');
}

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});

class FirebaseMessagingService {
  final _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Firebase Messaging servisi başlatılıyor...');
      
      // Background handler'ı ayarla
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      debugPrint('Background message handler ayarlandı');

      // Foreground handler'ı ayarla
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Ön planda bildirim alındı:');
        debugPrint('📝 MessageId: ${message.messageId}');
        debugPrint('📌 Başlık: ${message.notification?.title}');
        debugPrint('📄 İçerik: ${message.notification?.body}');
        debugPrint('🔍 Data: ${message.data}');
        debugPrint('📱 Notification: ${message.notification?.toMap()}');
      });
      debugPrint('Foreground message handler ayarlandı');

      // Bildirime tıklanma handler'ı
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('👆 Bildirime tıklandı:');
        debugPrint('📝 MessageId: ${message.messageId}');
        debugPrint('📌 Başlık: ${message.notification?.title}');
        debugPrint('📄 İçerik: ${message.notification?.body}');
        debugPrint('🔍 Data: ${message.data}');
      });
      debugPrint('Message opened handler ayarlandı');

      // Bildirim izinlerini iste
      final settings = await _requestPermissions();
      debugPrint('📱 Bildirim izinleri durumu: ${settings.authorizationStatus}');

      // Bildirim ayarlarını yap
      await _setupNotificationSettings();
      debugPrint('Bildirim ayarları yapılandırıldı');

      // FCM token al
      final token = await _messaging.getToken();
      debugPrint('📲 FCM Token alındı: $token');

      _isInitialized = true;
      debugPrint('✅ Firebase Messaging servisi başarıyla başlatıldı');
    } catch (e, stack) {
      debugPrint('❌ Firebase Messaging servisi başlatılırken hata: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  Future<NotificationSettings> _requestPermissions() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
      carPlay: false,
    );
  }

  Future<void> _setupNotificationSettings() async {
    // Foreground bildirim ayarları
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android için bildirim kanalı oluştur
    if (!kIsWeb) {
      const androidNotificationChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Önemli Bildirimler',
        description: 'Bu kanal önemli bildirimleri gösterir',
        importance: Importance.high,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
        playSound: true,
      );

      // Bildirim kanalını kaydet
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
