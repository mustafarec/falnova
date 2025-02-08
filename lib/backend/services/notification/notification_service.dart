library notification_service;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/notification/notification.dart';
import 'package:falnova/backend/models/notification/notification_settings.dart';
import 'package:logger/logger.dart';
import 'package:falnova/backend/services/notification/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:falnova/backend/services/notification/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
  final _fcmService = FCMService();
  final _supabase = Supabase.instance.client;
  List<Notification>? _cachedNotifications;
  DateTime? _lastFetch;
  static const _cacheTimeout = Duration(seconds: 10); // Test için 10 saniye
  bool _isInitialized = false;

  NotificationService._();
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      try {
        await _fcmService.initialize();
        _isInitialized = true;
        _logger.i('Bildirim servisi başlatıldı');
      } catch (e) {
        _logger.w('FCM servisi başlatılamadı, bildirimler devre dışı: $e');
        // FCM hatası durumunda bile servisi başlatmış say
        _isInitialized = true;
      }
    } catch (e) {
      _logger.e('Bildirim servisi başlatılırken kritik hata: $e');
      rethrow;
    }
  }

  Future<void> reinitialize() async {
    _isInitialized = false;
    try {
      await initialize();
    } catch (e) {
      _logger.w('Bildirim servisi yeniden başlatılamadı: $e');
    }
  }

  // Bildirimleri getir
  Future<List<Notification>> getNotifications() async {
    try {
      // Cache kontrolü - eğer cache null değilse ve timeout aşılmamışsa
      if (_cachedNotifications != null && _lastFetch != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetch!) < _cacheTimeout) {
          _logger.i(
              'Cache\'den ${_cachedNotifications!.length} bildirim yüklendi');
          return _cachedNotifications!;
        }
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Supabase'den yeni verileri al
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .or('type.neq.scheduled,and(type.eq.scheduled,scheduled_time.lte.now())')
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isEmpty) {
        _cachedNotifications = [];
        _lastFetch = DateTime.now();
        _logger.i('Bildirim bulunamadı');
        return [];
      }

      final List<Notification> notifications = [];
      for (final json in response) {
        try {
          DateTime? createdAt;

          try {
            createdAt = json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null;
          } catch (e) {
            _logger.w('Tarih dönüştürülürken hata: ${json['id']} - $e');
          }

          final notification = Notification(
            id: json['id'] as String? ?? '',
            userId: json['user_id'] as String? ?? '',
            type: json['type'] as String? ?? '',
            title: json['title'] as String? ?? '',
            body: json['body'] as String? ?? '',
            isRead: json['is_read'] as bool? ?? false,
            createdAt: createdAt ?? DateTime.now(),
            data: json['data'] as Map<String, dynamic>?,
          );

          notifications.add(notification);
        } catch (e) {
          _logger.e('Bildirim dönüştürülürken hata: ${json['id']} - $e');
          continue;
        }
      }

      // Cache güncelle
      _cachedNotifications = notifications;
      _lastFetch = DateTime.now();

      _logger.i('${notifications.length} bildirim başarıyla yüklendi');
      return notifications;
    } catch (e, stack) {
      _logger.e('Bildirimler yüklenirken hata: $e\n$stack');
      rethrow;
    }
  }

  // Cache'i temizle
  void clearCache() {
    _cachedNotifications = null;
    _lastFetch = null;
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      clearCache(); // Cache'i temizle
    } catch (e, stack) {
      _logger.e('Bildirim okundu işaretlenirken hata: $e\n$stack');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
      clearCache(); // Cache'i temizle
    } catch (e, stack) {
      _logger.e('Tüm bildirimler okundu işaretlenirken hata: $e\n$stack');
      rethrow;
    }
  }

  // Bildirim ayarlarını getir
  Future<NotificationSettings> getNotificationSettings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Kullanıcı oturumu bulunamadı');
    }

    try {
      _logger.i('Kullanıcı ID: $userId için bildirim ayarları alınıyor...');

      // Önce mevcut ayarları kontrol et
      final response = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      _logger.i('Mevcut ayarlar: $response');

      if (response == null) {
        _logger.i('Ayarlar bulunamadı, yeni ayarlar oluşturuluyor...');

        // Varsayılan ayarları hazırla
        final Map<String, dynamic> defaultSettings = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'user_id': userId,
          'horoscope_reminder_enabled': true,
          'coffee_reminder_enabled': true,
          'horoscope_reminder_time': '09:00',
          'coffee_reminder_time': ['09:00'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        _logger.i('Eklenecek varsayılan ayarlar: $defaultSettings');

        // Yeni ayarları ekle
        await _supabase.from('notification_settings').insert(defaultSettings);

        // Eklenen ayarları getir
        final newSettings = await _supabase
            .from('notification_settings')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (newSettings == null) {
          throw Exception('Ayarlar oluşturulamadı');
        }

        _logger.i('Eklenen ayarlar: $newSettings');
        return NotificationSettings.fromJson(newSettings);
      }

      _logger.i('Mevcut ayarlar dönülüyor...');
      return NotificationSettings.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Bildirim ayarları alınırken hata: $e');
      _logger.e('Hata stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      await _supabase.from('notifications').delete().eq('user_id', userId);
    } catch (e, stack) {
      _logger.e('Tüm bildirimler silinirken hata: $e\n$stack');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e, stack) {
      _logger.e('Bildirim silinirken hata: $e\n$stack');
      rethrow;
    }
  }

  Future<void> scheduleAllNotifications(NotificationSettings settings) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı');

      _logger.i('Bildirim planlaması başlatılıyor...');
      _logger.i('Ayarlar: ${settings.toJson()}');

      // Önce mevcut planlanmış bildirimleri sil
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_sent', false)
          .eq('type', 'scheduled');

      _logger.i('Mevcut planlanmış bildirimler silindi');

      // Kahve falı bildirimleri için
      if (settings.coffeeReminderEnabled) {
        _logger.i('Kahve falı bildirimleri planlanıyor...');
        _logger.i('Planlanan zamanlar: ${settings.coffeeReminderTime}');

        for (String timeStr in settings.coffeeReminderTime) {
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          var scheduledDate = DateTime.now();
          scheduledDate = DateTime(
            scheduledDate.year,
            scheduledDate.month,
            scheduledDate.day,
            hour,
            minute,
          );

          // Eğer zaman geçmişse, sonraki güne planla
          if (scheduledDate.isBefore(DateTime.now())) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          // Bildirimi ekle
          await _supabase.from('notifications').insert({
            'user_id': userId,
            'type': 'scheduled',
            'title': 'Kahve Falı Zamanı',
            'body': 'Günlük kahve falınızı baktırmayı unutmayın!',
            'scheduled_time': scheduledDate.toUtc().toIso8601String(),
            'is_sent': false,
            'data': {'type': 'coffee', 'priority': 'high'}
          });
          _logger.i(
              'Kahve falı bildirimi planlandı: $timeStr için ${scheduledDate.toIso8601String()}');
        }
      }

      // Burç yorumu bildirimleri için
      if (settings.horoscopeReminderEnabled &&
          settings.horoscopeReminderTime.isNotEmpty) {
        _logger.i('Burç yorumu bildirimi planlanıyor...');
        _logger.i('Planlanan zamanlar: ${settings.horoscopeReminderTime}');

        for (String timeStr in settings.horoscopeReminderTime) {
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          var scheduledDate = DateTime.now();
          scheduledDate = DateTime(
            scheduledDate.year,
            scheduledDate.month,
            scheduledDate.day,
            hour,
            minute,
          );

          // Eğer zaman geçmişse, sonraki güne planla
          if (scheduledDate.isBefore(DateTime.now())) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          // Bildirimi ekle
          await _supabase.from('notifications').insert({
            'user_id': userId,
            'type': 'scheduled',
            'title': 'Günlük Burç Yorumunuz Hazır',
            'body': 'Bugün sizin için neler olacağını öğrenin!',
            'scheduled_time': scheduledDate.toUtc().toIso8601String(),
            'is_sent': false,
            'data': {'type': 'horoscope', 'priority': 'high'}
          });
          _logger.i(
              'Burç yorumu bildirimi planlandı: $timeStr için ${scheduledDate.toIso8601String()}');
        }
      }

      _logger.i('Tüm bildirimler başarıyla planlandı');
    } catch (e, stack) {
      _logger.e('Bildirimler planlanırken hata: $e\n$stack');
      rethrow;
    }
  }

  Future<void> scheduleNotifications(NotificationSettings settings) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _logger.w('User session not found');
        return;
      }

      await _supabase.from('notification_settings').upsert(settings.toJson());
      _logger.i('Notification settings updated successfully');
    } catch (e, stack) {
      _logger.e('Error scheduling notifications', error: e, stackTrace: stack);
    }
  }
}
