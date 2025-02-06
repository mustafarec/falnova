import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/astrology/horoscope.dart';
import 'package:falnova/backend/services/fortune/gpt_service.dart';

final horoscopeServiceProvider = Provider((ref) => HoroscopeService(
      gptService: ref.watch(gptServiceProvider),
    ));

class HoroscopeService {
  final GptService gptService;

  HoroscopeService({required this.gptService});

  Future<Horoscope> getDailyHoroscope(String sign) async {
    try {
      final prompt =
          '''Sen bir astrologsun. $sign burcu için günlük yorum yapacaksın.
      Yanıtını tam olarak aşağıdaki formatta ver:

      [YORUM]
      (Burç için genel günlük yorum buraya)

      [PUANLAR]
      Aşk: X/10
      Kariyer: X/10
      Para: X/10
      Sağlık: X/10

      [ŞANS FAKTÖRLERİ]
      Şans Sayısı: X
      Şans Rengi: (renk adı)

      Not: Puanları 1-10 arası ver. Yorum samimi ve pozitif olmalı. Türkçe yanıt ver.''';

      final response = await gptService.generateContent(prompt);

      // Yanıtı parse et
      final lines = response.split('\n');
      String dailyHoroscope = '';
      Map<String, int> scores = {};
      String? luckNumber;
      String? luckColor;
      bool parsingScores = false;

      for (final line in lines) {
        final trimmedLine = line.trim();

        if (trimmedLine == '[PUANLAR]') {
          parsingScores = true;
          continue;
        } else if (trimmedLine == '[ŞANS FAKTÖRLERİ]') {
          parsingScores = false;
          continue;
        }

        if (parsingScores) {
          if (trimmedLine.toLowerCase().contains('aşk:')) {
            scores['love'] = _extractScore(trimmedLine);
          } else if (trimmedLine.toLowerCase().contains('kariyer:')) {
            scores['career'] = _extractScore(trimmedLine);
          } else if (trimmedLine.toLowerCase().contains('para:')) {
            scores['money'] = _extractScore(trimmedLine);
          } else if (trimmedLine.toLowerCase().contains('sağlık:')) {
            scores['health'] = _extractScore(trimmedLine);
          }
        } else if (trimmedLine.toLowerCase().contains('şans sayısı:')) {
          luckNumber = trimmedLine.split(':').last.trim();
        } else if (trimmedLine.toLowerCase().contains('şans rengi:')) {
          luckColor = trimmedLine.split(':').last.trim();
        } else if (!trimmedLine.startsWith('[') && trimmedLine.isNotEmpty) {
          dailyHoroscope += '$trimmedLine\n';
        }
      }

      // Eksik puanları varsayılan değerle doldur
      final requiredScores = ['love', 'career', 'money', 'health'];
      for (final score in requiredScores) {
        scores.putIfAbsent(score, () => 5);
      }

      return Horoscope(
        sign: sign,
        dailyHoroscope: dailyHoroscope.trim(),
        date: DateTime.now(),
        scores: scores,
        luckNumber: luckNumber,
        luckColor: luckColor,
      );
    } catch (e) {
      throw Exception('Günlük burç yorumu alınırken bir hata oluştu: $e');
    }
  }

  int _extractScore(String line) {
    final regex = RegExp(r'(\d+)/10');
    final match = regex.firstMatch(line);
    if (match != null) {
      final score = int.parse(match.group(1)!);
      return score > 10 ? 10 : score;
    }
    return 5; // Varsayılan değer
  }
}
