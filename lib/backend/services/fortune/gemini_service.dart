import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final gptServiceProvider = Provider((ref) => GptService());

class GptService {
  final _dio = Dio();
  final _baseUrl = 'https://api.openai.com/v1';
  final _model = 'gpt-4-turbo-preview';
  final _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
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
          'top_p': 0.95,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'] as String;
        }
        throw Exception('Yanıt alınamadı');
      } else {
        throw Exception('API yanıt vermedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fal yorumlanırken bir hata oluştu: $e');
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
          'top_p': 0.95,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'] as String;
        }
        throw Exception('Yanıt alınamadı');
      } else {
        throw Exception('API yanıt vermedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fal yorumlanırken bir hata oluştu: $e');
    }
  }
}
