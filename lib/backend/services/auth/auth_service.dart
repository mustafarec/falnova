import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
      },
    );

    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase.auth.updateUser(
      UserAttributes(
        data: updates,
      ),
    );
  }

  Future<bool> isEmailVerified() async {
    final user = currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  Future<void> sendVerificationEmail() async {
    final user = currentUser;
    if (user == null) return;
    // Email doğrulama işlemi Supabase tarafından otomatik olarak yapılıyor
  }

  Future<bool> isPremiumUser() async {
    final user = currentUser;
    if (user == null) return false;
    return user.userMetadata?['is_premium'] == true;
  }
}
