import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/backend/models/user/user_profile.dart';
import 'package:falnova/backend/models/user/user_stats.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:falnova/core/config/router.dart' show rootNavigatorKey;

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(supabaseServiceProvider));
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.read(userRepositoryProvider).getCurrentUserProfile();
});

final userStatsProvider = FutureProvider<UserStats?>((ref) async {
  return ref.read(userRepositoryProvider).getCurrentUserStats();
});

class UserRepository {
  final SupabaseService _supabase;
  final _logger = Logger();

  UserRepository(this._supabase);

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      _logger.d('Getting current user profile');
      final user = _supabase.client.auth.currentUser;
      _logger.d('Current user: ${user?.id}');

      if (user == null) {
        _logger.w('No user found');
        return null;
      }

      final response = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _logger.d('Raw profile response: $response');

      // Veriyi UserProfile formatına uygun hale getir
      final Map<String, dynamic> profileData = {
        'id': user.id,
        'email': user.email,
        'first_name': response['first_name'],
        'last_name': response['last_name'],
        'photo_url': response['photo_url'],
        'birth_date': response['birth_date'],
        'birth_city': response['birth_city'],
        'gender': response['gender'],
        'zodiac_sign': response['zodiac_sign'],
        'rising_sign': response['rising_sign'],
        'moon_sign': response['moon_sign'],
        'favorite_coffee_type': response['favorite_coffee_type'],
        'reading_preference': response['reading_preference'] ?? 'detailed',
        'is_premium': response['is_premium'] ?? false,
        'created_at':
            response['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at':
            response['updated_at'] ?? DateTime.now().toIso8601String(),
      };

      _logger.d('Formatted profile data: $profileData');

      final profile = UserProfile.fromJson(profileData);
      _logger.d('Profile parsed: $profile');

      return profile;
    } catch (e, stack) {
      _logger.e('Error getting user profile', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<UserStats?> getCurrentUserStats() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase.client
          .from('user_stats')
          .select()
          .eq('id', user.id)
          .single();

      return UserStats.fromJson(response);
    } catch (e, stack) {
      _logger.e('Error getting user stats', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) throw Exception('User not found');

      // Sadece profil alanlarını içeren map oluştur
      final updateData = {
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'birth_date': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
        'zodiac_sign': profile.zodiacSign,
        'rising_sign': profile.risingSign,
        'moon_sign': profile.moonSign,
        'favorite_coffee_type': profile.favoriteCoffeeType,
        'reading_preference': profile.readingPreference,
        'updated_at': DateTime.now().toIso8601String(),
      };

      _logger.d('Updating profile with data: $updateData');

      await _supabase.client
          .from('profiles')
          .update(updateData)
          .eq('id', user.id);

      _logger.i('Profile updated successfully');
    } catch (e, stack) {
      _logger.e('Error updating user profile', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateStats(UserStats stats) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) throw Exception('User not found');

      await _supabase.client
          .from('user_stats')
          .update(stats.toJson())
          .eq('id', user.id);
    } catch (e, stack) {
      _logger.e('Error updating user stats', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) throw Exception('User not found');

      await _supabase.client
          .from('profiles')
          .update({'photo_url': photoUrl}).eq('id', user.id);
    } catch (e, stack) {
      _logger.e('Error updating profile photo', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) throw Exception('User not found');

      await _supabase.client
          .from('profiles')
          .update({'is_premium': isPremium}).eq('id', user.id);
    } catch (e, stack) {
      _logger.e('Error updating premium status', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _logger.i('Çıkış işlemi başlatılıyor...');

      // 1. FCM token'ı sil
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _supabase.client.from('fcm_tokens').delete().eq('token', token);
          _logger.i('FCM token silindi');
        }
      } catch (e) {
        _logger.w('FCM token silinirken hata: $e');
      }

      // 2. Local verileri temizle
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _logger.i('Local veriler temizlendi');
      } catch (e) {
        _logger.w('Local veriler temizlenirken hata: $e');
      }

      // 3. Auth state'i güncelle
      await _supabase.client.auth.signOut();
      _logger.i('Auth oturumu kapatıldı');

      // 4. Router'ı zorla güncelle
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      _logger.e('Çıkış yapılırken hata oluştu', error: e);
      rethrow;
    }
  }
}
