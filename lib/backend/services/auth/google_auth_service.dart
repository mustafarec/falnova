import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:falnova/backend/services/preferences_service.dart';
import 'package:falnova/core/services/service_registry.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GoogleAuthService(PreferencesService(prefs));
});

class GoogleAuthService {
  final _supabase = Supabase.instance.client;
  final _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    serverClientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'],
  );
  final _logger = Logger();
  final PreferencesService _prefsService;

  GoogleAuthService(this._prefsService);

  Future<bool> checkRequiredFields(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return response['birth_date'] != null &&
          response['birth_time'] != null &&
          response['birth_city'] != null &&
          response['gender'] != null;
    } catch (e) {
      _logger.e('Kullanıcı bilgileri kontrol edilirken hata', error: e);
      return false;
    }
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      _logger.d('Google ile giriş başlatılıyor...');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google oturumu iptal edildi');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'Google access token alınamadı';
      }

      if (idToken == null) {
        throw 'Google ID token alınamadı';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        // Zorunlu alanları kontrol et
        final hasRequiredFields = await checkRequiredFields(response.user!.id);

        if (!hasRequiredFields) {
          _logger.d('Eksik bilgiler var, geçici veriler kaydediliyor...');

          // Geçici verileri kaydet
          await _prefsService.saveTempUserData({
            'email': response.user!.email,
            'first_name':
                response.user!.userMetadata?['full_name']?.split(' ')[0] ?? '',
            'last_name': response.user!.userMetadata?['full_name']
                    ?.split(' ')
                    .skip(1)
                    .join(' ') ??
                '',
            'is_google_user': true,
          });
        }
      }

      _logger.i('Google ile giriş başarılı: ${response.user?.email}');
      return response;
    } catch (e, stack) {
      _logger.e('Google ile giriş hatası', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _logger.i('Google oturumu kapatıldı');
    } catch (e, stack) {
      _logger.e('Google oturumu kapatılırken hata',
          error: e, stackTrace: stack);
      rethrow;
    }
  }
}
