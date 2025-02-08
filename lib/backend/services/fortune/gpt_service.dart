import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

final gptServiceProvider = Provider((ref) => GptService());

class GptService {
  final _dio = Dio();
  final _baseUrl = 'https://openrouter.ai/api/v1';
  final _model = 'google/gemini-2.0-pro-exp-02-05:free';
  final _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
  final _logger = Logger();

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
            'HTTP-Referer': 'https://falnova.app',
            'X-Title': 'FalNova',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            data['choices'] != null &&
            data['choices'] is List &&
            data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          if (choice != null &&
              choice['message'] != null &&
              choice['message']['content'] != null) {
            return choice['message']['content'] as String;
          }
        }
        throw Exception('API yanıtı beklenen formatta değil');
      } else {
        throw Exception('API yanıt vermedi: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('API Hatası: $e');
      _logger.e(
          'API Yanıtı: ${e is DioException ? e.response?.data : 'Bilinmeyen yanıt'}');
      throw Exception('İçerik oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String> generateContentWithImage(
      String prompt, String base64Image) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
            'HTTP-Referer': 'https://falnova.app',
            'X-Title': 'FalNova',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            data['choices'] != null &&
            data['choices'] is List &&
            data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          if (choice != null &&
              choice['message'] != null &&
              choice['message']['content'] != null) {
            return choice['message']['content'] as String;
          }
        }
        throw Exception('API yanıtı beklenen formatta değil');
      } else {
        throw Exception('API yanıt vermedi: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('API Hatası: $e');
      _logger.e(
          'API Yanıtı: ${e is DioException ? e.response?.data : 'Bilinmeyen yanıt'}');
      throw Exception('İçerik oluşturulurken bir hata oluştu: $e');
    }
  }
}
