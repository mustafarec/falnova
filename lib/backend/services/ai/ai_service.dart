import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../fortune/gpt_service.dart';

class AiServiceException implements Exception {
  final String code;
  final String message;

  AiServiceException(this.code, this.message);

  @override
  String toString() => message;
}

final aiServiceProvider = Provider<AiService>((ref) {
  final gptService = ref.watch(gptServiceProvider);
  return AiService(gptService);
});

class AiService {
  final GptService _gptService;

  AiService(this._gptService);

  Future<String> interpretCoffeeReading(String imageUrl) async {
    try {
      final prompt = '''Türk kahvesi fincanındaki şekilleri yorumla. 
      Detaylı ve olumlu bir yorum yap. 
      Aşk, kariyer, sağlık ve para konularına değin.
      Fincan: $imageUrl''';

      final response = await _gptService.generateContent(prompt);
      return response;
    } catch (e) {
      throw Exception('Kahve falı yorumlanırken bir hata oluştu: $e');
    }
  }

  Future<String> generateHoroscope(String zodiacSign) async {
    try {
      final prompt = '''$zodiacSign burcu için günlük yorum yap.
      Aşk, iş ve genel konularda olumlu tahminlerde bulun.
      Motivasyon verici ve yapıcı bir dil kullan.''';

      final response = await _gptService.generateContent(prompt);
      return response;
    } catch (e) {
      throw Exception('Günlük burç yorumu oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String> generateContentWithImage(
      String prompt, String base64Image) async {
    try {
      final response =
          await _gptService.generateContentWithImage(prompt, base64Image);
      return response;
    } catch (e) {
      throw Exception('Görüntü analizi sırasında bir hata oluştu: $e');
    }
  }
}
