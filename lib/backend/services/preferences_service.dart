import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/core/services/service_registry.dart';

final _logger = Logger();

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
});

class PreferencesService {
  static const String _tempUserDataKey = 'temp_user_data';
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Geçici kullanıcı verilerini kaydet
  Future<void> saveTempUserData(Map<String, dynamic> userData) async {
    try {
      final jsonData = json.encode(userData);
      await _prefs.setString(_tempUserDataKey, jsonData);
      _logger.d('Geçici kullanıcı verileri kaydedildi: $userData');
    } catch (e) {
      _logger.e('Geçici kullanıcı verileri kaydedilemedi', error: e);
      rethrow;
    }
  }

  // Geçici kullanıcı verilerini getir
  Map<String, dynamic>? getTempUserData() {
    try {
      final jsonData = _prefs.getString(_tempUserDataKey);
      if (jsonData != null) {
        return json.decode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Geçici kullanıcı verileri alınamadı', error: e);
      return null;
    }
  }

  // Geçici kullanıcı verilerini temizle
  Future<void> clearTempUserData() async {
    try {
      await _prefs.remove(_tempUserDataKey);
      _logger.d('Geçici kullanıcı verileri temizlendi');
    } catch (e) {
      _logger.e('Geçici kullanıcı verileri temizlenemedi', error: e);
      rethrow;
    }
  }

  // Geçici kullanıcı verilerine yeni veri ekle
  Future<void> updateTempUserData(Map<String, dynamic> newData) async {
    try {
      final currentData = getTempUserData() ?? {};
      currentData.addAll(newData);
      await saveTempUserData(currentData);
      _logger.d('Geçici kullanıcı verileri güncellendi: $newData');
    } catch (e) {
      _logger.e('Geçici kullanıcı verileri güncellenemedi', error: e);
      rethrow;
    }
  }
}
