import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/core/models/initialization_state.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/backend/services/notification/notification_service.dart';
import 'package:logger/logger.dart';
import 'dart:async';

final _logger = Logger();

final initializationProvider =
    StateNotifierProvider<InitializationNotifier, InitializationState>((ref) {
  return InitializationNotifier(ref);
});

class InitializationNotifier extends StateNotifier<InitializationState> {
  final Ref _ref;

  InitializationNotifier(this._ref)
      : super(const InitializationState(
          isInitialized: false,
          isLoading: false,
          error: null,
          loadingMessage: null,
        ));

  Future<void> initialize() async {
    if (state.isInitialized || state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);

      // Supabase Service (Kritik)
      final supabaseService = _ref.read(supabaseServiceProvider);
      if (!supabaseService.isInitialized) {
        state = state.copyWith(loadingMessage: 'Oturum kontrol ediliyor...');
        await supabaseService.initialize();
        if (!supabaseService.isInitialized) {
          throw Exception('Oturum başlatılamadı');
        }
        _logger.i('Oturum kontrolü tamamlandı');
      }

      // Firebase ve bildirim servisleri kontrol
      try {
        await _initializeNonCriticalServices();
      } catch (e) {
        _logger.w('Bildirim servisleri başlatılamadı, devam ediliyor...',
            error: e);
      }

      // Başlatma tamamlandı
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        loadingMessage: null,
      );
    } catch (e, stack) {
      _logger.e('Servisler başlatılırken hata', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        loadingMessage: null,
      );
    }
  }

  Future<void> _initializeNonCriticalServices() async {
    try {
      // FCM ve diğer bildirim servisleri
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.initialize();
      _logger.i('Bildirim servisi başlatıldı');
    } catch (e, stack) {
      _logger.e('Bildirim servisleri başlatılamadı',
          error: e, stackTrace: stack);
      rethrow;
    }
  }
}
