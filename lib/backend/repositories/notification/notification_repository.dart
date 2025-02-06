import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:falnova/backend/models/notification/notification.dart' as model;
import 'package:falnova/backend/models/notification/notification_settings.dart'
    as settings;
import 'package:falnova/backend/services/notification/notification_service.dart';
import 'package:falnova/backend/services/supabase_service.dart';

final _logger = Logger('NotificationRepository');

final notificationRepositoryProvider = StateNotifierProvider<
    NotificationRepository, AsyncValue<List<model.Notification>>>(
  (ref) => NotificationRepository(
    ref.read(supabaseServiceProvider),
    ref.read(notificationServiceProvider),
  ),
);

final notificationSettingsProvider = AsyncNotifierProvider<
    NotificationSettingsNotifier, settings.NotificationSettings?>(() {
  return NotificationSettingsNotifier();
});

class NotificationRepository
    extends StateNotifier<AsyncValue<List<model.Notification>>> {
  final SupabaseService _supabase;
  final NotificationService _notificationService;

  NotificationRepository(this._supabase, this._notificationService)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final user = _supabase.client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((json) => model.Notification.fromJson(json))
          .toList();

      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      _logger.severe('Error loading notifications: $e\n$stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    try {
      if (currentState is AsyncData<List<model.Notification>>) {
        final notifications = List<model.Notification>.from(currentState.value);
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification =
              notifications[index].copyWith(isRead: true);
          notifications[index] = updatedNotification;
          state = AsyncValue.data(notifications);

          await _supabase
              .from('notifications')
              .update({'is_read': true}).eq('id', notificationId);
        }
      }
    } catch (e, stack) {
      _logger.severe('Error marking notification as read: $e\n$stack');
      state = currentState;
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    try {
      if (currentState is AsyncData<List<model.Notification>>) {
        final notifications =
            currentState.value.map((n) => n.copyWith(isRead: true)).toList();
        state = AsyncValue.data(notifications);

        final user = _supabase.client.auth.currentUser;
        if (user != null) {
          await _supabase
              .from('notifications')
              .update({'is_read': true}).eq('user_id', user.id);
        }
      }
    } catch (e, stack) {
      _logger.severe('Error marking all notifications as read: $e\n$stack');
      state = currentState;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final currentState = state;
    try {
      if (currentState is AsyncData<List<model.Notification>>) {
        final notifications = List<model.Notification>.from(currentState.value);
        notifications.removeWhere((n) => n.id == notificationId);
        state = AsyncValue.data(notifications);

        await _supabase.from('notifications').delete().eq('id', notificationId);
      }
    } catch (e, stack) {
      _logger.severe('Error deleting notification: $e\n$stack');
      state = currentState;
    }
  }

  Future<void> deleteAllNotifications() async {
    final currentState = state;
    try {
      if (currentState is AsyncData<List<model.Notification>>) {
        state = const AsyncValue.data([]);

        final user = _supabase.client.auth.currentUser;
        if (user != null) {
          await _supabase.from('notifications').delete().eq('user_id', user.id);
        }
      }
    } catch (e, stack) {
      _logger.severe('Error deleting all notifications: $e\n$stack');
      state = currentState;
    }
  }

  Future<void> scheduleNotifications(
      settings.NotificationSettings settings) async {
    try {
      await _notificationService.scheduleNotifications(settings);
    } catch (e, stack) {
      _logger.severe('Error scheduling notifications: $e\n$stack');
    }
  }
}

class NotificationSettingsNotifier
    extends AsyncNotifier<settings.NotificationSettings?> {
  late final SupabaseService _supabase;
  late final Logger _logger;

  @override
  Future<settings.NotificationSettings?> build() async {
    _supabase = ref.read(supabaseServiceProvider);
    _logger = Logger('NotificationSettingsNotifier');
    try {
      return await _loadSettings();
    } catch (e, stack) {
      _logger.severe('Initial build failed: $e\n$stack');
      return Future.error(e, stack);
    }
  }

  Future<settings.NotificationSettings?> _loadSettings() async {
    try {
      _logger.info('Bildirim ayarları yükleniyor...');

      final user = _supabase.client.auth.currentUser;
      if (user == null) {
        _logger.warning('Kullanıcı oturumu bulunamadı');
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Retry mekanizması ekle
      for (int i = 0; i < 3; i++) {
        try {
          // Mevcut ayarları kontrol et
          final data = await _supabase.client
              .from('notification_settings')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

          if (data != null) {
            _logger.info('Mevcut ayarlar bulundu: $data');
            return settings.NotificationSettings.fromJson(data);
          }

          // Varsayılan ayarları oluştur
          final defaultSettings =
              settings.NotificationSettings.getDefaultSettings(user.id);

          // Kaydetmeyi dene
          final response = await _supabase.client
              .from('notification_settings')
              .insert(defaultSettings.toJson())
              .select()
              .single();

          _logger.info('Varsayılan ayarlar kaydedildi: $response');
          return settings.NotificationSettings.fromJson(response);
        } catch (e) {
          if (i == 2) {
            // Son deneme
            _logger.severe('Üç deneme sonrası başarısız oldu');
            rethrow;
          }
          _logger.warning('Deneme ${i + 1} başarısız, tekrar deneniyor...');
          await Future.delayed(
              Duration(milliseconds: 500 * (i + 1))); // Artan bekleme süresi
        }
      }

      throw Exception('Bildirim ayarları yüklenemedi');
    } catch (e, stack) {
      _logger.severe('Bildirim ayarları yüklenemedi: $e\n$stack');
      throw Exception('Bildirim ayarları yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> refreshSettings() async {
    try {
      state = const AsyncValue.loading();
      final result = await _loadSettings();
      state = AsyncValue.data(result);
    } catch (e, stack) {
      _logger.severe('Refresh failed: $e\n$stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(settings.NotificationSettings newSettings) async {
    try {
      _logger.info('Bildirim ayarları güncelleniyor...');
      state = const AsyncValue.loading();

      // Retry mekanizması ekle
      for (int i = 0; i < 3; i++) {
        try {
          final response = await _supabase.client
              .from('notification_settings')
              .upsert(newSettings.toJson())
              .select()
              .single();

          _logger.info('Ayarlar güncellendi: $response');
          final updatedSettings =
              settings.NotificationSettings.fromJson(response);

          // Bildirimleri planla
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.scheduleNotifications(updatedSettings);

          state = AsyncValue.data(updatedSettings);
          _logger.info('Bildirim ayarları başarıyla güncellendi');
          return;
        } catch (e) {
          if (i == 2) {
            // Son deneme
            rethrow;
          }
          _logger.warning(
              'Güncelleme denemesi ${i + 1} başarısız, tekrar deneniyor...');
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        }
      }
    } catch (e, stack) {
      _logger.severe('Bildirim ayarları güncellenemedi: $e\n$stack');
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
