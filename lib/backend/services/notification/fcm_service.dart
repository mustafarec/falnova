import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:falnova/core/config/router.dart' show rootNavigatorKey;
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Arka planda bildirim alındı: ${message.messageId}');
}

final fcmServiceProvider = Provider<FCMService>((ref) {
  final service = FCMService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class FCMService {
  final _messaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;
  static final _instance = FCMService._();
  bool _isInitialized = false;
  StreamSubscription<AuthState>? _authStateSubscription;

  // Retry parametreleri
  static const int _maxTokenRetries = 3;
  static const Duration _initialTokenRetryDelay = Duration(seconds: 2);
  static const Duration _sessionCheckDelay = Duration(milliseconds: 500);
  static const int _maxSessionChecks = 6; // 3 saniye toplam bekleme

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  StreamSubscription<RemoteMessage>? _messageSubscription;
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  FCMService._();
  factory FCMService() => _instance;

  void dispose() {
    _messageSubscription?.cancel();
    _authStateSubscription?.cancel();
    _isInitialized = false;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('FCM servisi zaten başlatılmış');
      return;
    }

    try {
      _logger.i('FCM servisi başlatılıyor...');

      // Önceki subscription'ı temizle
      await _messageSubscription?.cancel();

      // Background handler'ı ayarla
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      _logger.d('Background message handler ayarlandı');

      // Local notifications başlat
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: (details) {
          _logger.i('Local bildirime tıklandı: ${details.payload}');
          _handleNotificationTap(details.payload);
        },
      );
      _logger.d('Local notifications başlatıldı');

      // Android notification channel oluştur
      await _createNotificationChannel();

      // Foreground handler'ı ayarla
      _messageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        _logger.i('Ön planda bildirim alındı:');
        _logger.d('MessageId: $message.messageId');
        _logger.d('Title: ${message.notification?.title}');
        _logger.d('Body: ${message.notification?.body}');
        _logger.d('Data: ${message.data}');
        await _showLocalNotification(message);
      });

      // Bildirime tıklanma handler'ı
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Bildirime tıklandı:');
        _logger.d('MessageId: ${message.messageId}');
        _logger.d('Data: ${message.data}');
        _handleNotificationTap(message.data.toString());
      });

      // Token yönetimi sistemini başlat
      await _setupTokenRefresh();

      _isInitialized = true;
      _logger.i('FCM servisi başarıyla başlatıldı');
    } catch (e, stack) {
      _logger.e('FCM servisi başlatılırken hata', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Yüksek öncelikli bildirimler için kanal',
      importance: Importance.max,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _handleNotificationTap(String? payload) async {
    try {
      if (payload == null) {
        _logger.w('Bildirim verisi boş');
        return;
      }

      _logger.d('Bildirim verisi: $payload');

      // Payload'ı parse et
      final data = Map<String, String>.fromEntries(payload
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',')
          .map((item) {
        final parts = item.split(':');
        return MapEntry(parts[0].trim(), parts[1].trim().replaceAll('"', ''));
      }));

      final type = data['type'];
      final notificationId = data['id'];

      if (type != null && notificationId != null) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          switch (type) {
            case 'coffee':
            case 'coffee_reminder':
              context.push('/fortune/reading/$notificationId');
              break;
            case 'horoscope':
            case 'horoscope_reminder':
              context.push('/horoscope', extra: {'id': notificationId});
              break;
            default:
              _logger.w('Bilinmeyen bildirim tipi: $type');
              break;
          }
        } else {
          _logger.w('Navigator context bulunamadı');
        }
      } else {
        _logger.w('Geçersiz bildirim verisi: type=$type, id=$notificationId');
      }
    } catch (e, stack) {
      _logger.e('Bildirim yönlendirmesi yapılırken hata',
          error: e, stackTrace: stack);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;
      final data = message.data;

      if (notification != null) {
        final notificationId = message.messageId.hashCode;
        _logger.d('Push bildirimi gösteriliyor: ID=$notificationId');

        await _localNotifications.show(
          notificationId,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'Yüksek öncelikli bildirimler için kanal',
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              channelShowBadge: true,
              autoCancel: true,
              ticker: 'Yeni bildirim',
              visibility: NotificationVisibility.public,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: data.toString(),
        );

        _logger.d('Push bildirimi başarıyla gösterildi: ID=$notificationId');
      } else {
        _logger.w('Bildirim içeriği boş, gösterilmedi');
      }
    } catch (e, stack) {
      _logger.e('Push bildirimi gösterilirken hata',
          error: e, stackTrace: stack);
    }
  }

  Future<bool> _waitForSession() async {
    int attempts = 0;
    while (attempts < _maxSessionChecks) {
      if (_supabase.auth.currentUser != null) {
        return true;
      }
      await Future.delayed(_sessionCheckDelay);
      attempts++;
    }
    return false;
  }

  Future<void> _saveFCMToken(String token) async {
    int retryCount = 0;
    while (retryCount < _maxTokenRetries) {
      try {
        // Session kontrolü
        final hasSession = await _waitForSession();
        if (!hasSession) {
          _logger.w('Oturum bulunamadı, token kaydı erteleniyor...');
          retryCount++;
          if (retryCount < _maxTokenRetries) {
            await Future.delayed(_initialTokenRetryDelay * retryCount);
            continue;
          }
          return;
        }

        final user = _supabase.auth.currentUser;
        if (user == null) {
          _logger.w('Kullanıcı oturumu bulunamadı, token kaydı erteleniyor...');
          retryCount++;
          if (retryCount < _maxTokenRetries) {
            await Future.delayed(_initialTokenRetryDelay * retryCount);
            continue;
          }
          return;
        }

        _logger.i('FCM token kontrol ediliyor...');

        // Önce kullanıcının eski token'larını sil
        await _supabase.from('fcm_tokens').delete().eq('user_id', user.id);

        _logger.i('FCM token kaydediliyor...');
        _logger.d('UserId: ${user.id}');
        _logger.d('Token: ${token.substring(0, 10)}...');

        // Yeni token'ı kaydet
        await _supabase.from('fcm_tokens').insert({
          'user_id': user.id,
          'token': token,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        _logger.i('FCM token başarıyla kaydedildi');
        return; // Başarılı kayıt, döngüden çık
      } catch (e) {
        _logger.e(
            'FCM token kaydedilirken hata (Deneme ${retryCount + 1}/$_maxTokenRetries)',
            error: e);
        retryCount++;
        if (retryCount < _maxTokenRetries) {
          await Future.delayed(_initialTokenRetryDelay * retryCount);
        }
      }
    }
  }

  Future<void> _setupTokenRefresh() async {
    try {
      _logger.d('Token yenileme sistemi başlatılıyor...');

      // Auth state değişikliklerini dinle
      _authStateSubscription?.cancel();
      _authStateSubscription =
          _supabase.auth.onAuthStateChange.listen((data) async {
        final event = data.event;
        _logger.d('Auth state değişti: $event');

        if (event == AuthChangeEvent.signedIn) {
          // Oturum açıldığında token'ı kaydet
          final token = await _messaging.getToken();
          if (token != null) {
            await _saveFCMToken(token);
          }
        } else if (event == AuthChangeEvent.signedOut) {
          // Oturum kapandığında token'ı sil
          final token = await _messaging.getToken();
          if (token != null) {
            await deleteToken(token);
          }
        }
      });

      // İlk token'ı al ve kaydet
      final initialToken = await _messaging.getToken();
      if (initialToken != null) {
        await _saveFCMToken(initialToken);
      }

      // Token yenilendiğinde
      _messaging.onTokenRefresh.listen((String token) async {
        _logger.i('FCM token yenilendi');
        await _saveFCMToken(token);
      });

      _logger.d('Token yenileme sistemi başarıyla başlatıldı');
    } catch (e) {
      _logger.e('Token yenileme sistemi başlatılırken hata', error: e);
    }
  }

  Future<void> deleteToken(String token) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final user = _supabase.auth.currentUser;
        if (user == null) return;

        await _supabase
            .from('fcm_tokens')
            .delete()
            .match({'user_id': user.id, 'token': token});

        _logger.i('FCM token başarıyla silindi');
        return;
      } catch (e) {
        retryCount++;
        _logger.w(
            'FCM token silinirken hata (Deneme $retryCount/$_maxRetries): $e');

        if (retryCount < _maxRetries) {
          await Future.delayed(_retryDelay * retryCount);
        } else {
          _logger.e('FCM token silinemedi, maksimum deneme sayısına ulaşıldı');
          rethrow;
        }
      }
    }
  }
}
