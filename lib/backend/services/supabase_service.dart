import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _logger = Logger();

  SupabaseClient get client {
    _logger.d('Getting Supabase client');
    final client = Supabase.instance.client;
    _logger.d('Client initialized');
    return client;
  }

  bool get isInitialized {
    final initialized = true;
    _logger.d('Supabase initialized: $initialized');
    return initialized;
  }

  User? get currentUser {
    final user = client.auth.currentUser;
    _logger.d('Current user: ${user?.id}');
    return user;
  }

  bool get isAuthenticated {
    final authenticated = currentUser != null;
    _logger.d('Is authenticated: $authenticated');
    return authenticated;
  }

  // Supabase veritabanı işlemleri için yardımcı metodlar
  SupabaseQueryBuilder from(String table) {
    _logger.d('Creating query builder for table: $table');
    return client.from(table);
  }

  GoTrueClient get auth => client.auth;

  Future<void> initialize() async {
    _logger.d('Initializing Supabase service');
    if (isInitialized) {
      _logger.d('Already initialized');
      return;
    }
    try {
      await Supabase.instance.client.auth.refreshSession();
      _logger.d('Session refreshed successfully');
    } catch (e) {
      _logger.e('Error refreshing session', error: e);
      rethrow;
    }
  }
}
