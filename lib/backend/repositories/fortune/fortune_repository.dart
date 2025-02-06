import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/fortune/fortune_models.dart';
import 'package:falnova/backend/services/fortune/gpt_service.dart';
import 'package:falnova/backend/services/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final fortuneRepositoryProvider =
    StateNotifierProvider<FortuneRepository, List<FortuneReading>>((ref) {
  final gptService = ref.watch(gptServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return FortuneRepository(
      gptService: gptService, storageService: storageService);
});

class FortuneRepository extends StateNotifier<List<FortuneReading>> {
  final GptService gptService;
  final StorageService storageService;
  final _supabase = Supabase.instance.client;
  final _logger = Logger();

  FortuneRepository({
    required this.gptService,
    required this.storageService,
  }) : super([]);

  Future<FortuneReading> getFortuneTelling(
      String imageBase64, String imagePath) async {
    try {
      final interpretation = await gptService.generateContentWithImage(
        '''Bu bir Türk kahve fincanı fotoğrafı. 
        Lütfen fincandaki şekilleri detaylı bir şekilde yorumla ve kahve falı bak. 
        Yanıtını Türkçe olarak ver ve falcı gibi konuş.
        Yanıtını şu bölümlere ayır:
        - Fincanın Genel Görünümü
        - Aşk ve İlişkiler
        - İş ve Kariyer
        - Sağlık
        - Yakın Gelecek''',
        imageBase64,
      );
      final imageUrl = await storageService.uploadFortuneImage(imagePath);
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _supabase
          .from('fortune_readings')
          .insert({
            'image_url': imageUrl,
            'interpretation': interpretation,
            'is_premium': false,
            'created_at': DateTime.now().toIso8601String(),
            'user_id': user.id,
          })
          .select()
          .single();

      final reading = FortuneReading.fromJson(response);
      state = [...state, reading];
      return reading;
    } catch (e, stack) {
      _logger.e('Kahve falı alınırken hata', error: e, stackTrace: stack);
      throw Exception('Kahve falı alınırken bir hata oluştu: $e');
    }
  }

  Future<void> deleteFortune(FortuneReading reading) async {
    try {
      state = state.where((f) => f.id != reading.id).toList();
      await _supabase.from('fortune_readings').delete().eq('id', reading.id);
    } catch (e) {
      _logger.e('Silme hatası: $e');
      rethrow;
    }
  }

  Future<void> restoreFortune(FortuneReading reading) async {
    try {
      state = [...state, reading];

      await _supabase.from('fortune_readings').insert({
        'id': reading.id,
        'image_url': reading.imageUrl,
        'interpretation': reading.interpretation,
        'created_at': reading.createdAt.toIso8601String(),
        'is_premium': reading.isPremium,
        'user_id': reading.userId,
      });
    } catch (e) {
      state = state.where((f) => f.id != reading.id).toList();
      _logger.e('Fal geri yükleme hatası: $e');
      rethrow;
    }
  }

  List<FortuneReading> getRecentReadings() {
    return state.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<FortuneReading>> getFortuneHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await _supabase.from('fortune_readings').select('''
            id,
            image_url,
            interpretation,
            created_at,
            is_premium,
            user_id
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      final readings = (response as List)
          .map((data) => FortuneReading.fromJson(data as Map<String, dynamic>))
          .toList();

      state = readings;
      return readings;
    } catch (e, stack) {
      _logger.e('Fal geçmişi alınırken hata', error: e, stackTrace: stack);
      throw Exception('Fal geçmişi alınırken bir hata oluştu: $e');
    }
  }

  Future<void> saveFortune(FortuneReading fortune) async {
    try {
      await _supabase.from('fortune_readings').insert({
        'image_url': fortune.imageUrl,
        'interpretation': fortune.interpretation,
        'is_premium': fortune.isPremium,
        'created_at': fortune.createdAt.toIso8601String(),
        'user_id': fortune.userId,
      });
    } catch (e, stack) {
      _logger.e('Fal kaydedilirken hata', error: e, stackTrace: stack);
      throw Exception('Fal kaydedilirken bir hata oluştu: $e');
    }
  }

  /// Fal durumunu kontrol eder
  Future<String> checkFortuneStatus(String fortuneId) async {
    try {
      final response = await _supabase
          .from('fortune_readings')
          .select('status')
          .eq('id', fortuneId)
          .single();

      return response['status'] as String? ?? 'error';
    } catch (e, stack) {
      _logger.e('Fal durumu kontrol edilirken hata',
          error: e, stackTrace: stack);
      return 'error';
    }
  }
}
