import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ImageValidationService {
  static final _logger = Logger();

  static Future<bool> isCoffeeCupImage(String imagePath) async {
    try {
      final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
      final dio = Dio();
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://falnova.app',
            'X-Title': 'FalNova',
          },
        ),
        data: {
          'model': 'google/gemini-2.0-pro-exp-02-05:free',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      'Bu fotoğrafta bir Türk kahvesi fincanı veya tabağı var mı? Sadece "evet" veya "hayır" olarak cevap ver.',
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
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          final result = choices[0]['message']['content'] as String;
          return result.toLowerCase().contains('evet');
        }
      }
      return false;
    } catch (e) {
      _logger.e('Görüntü doğrulama hatası', error: e);
      return false;
    }
  }

  static String getValidationErrorMessage() {
    return 'Fotoğrafta kahve fincanı veya tabağı tespit edilemedi. Lütfen fincanın net göründüğü bir fotoğraf yükleyin.';
  }
}
