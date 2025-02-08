import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/astrology/horoscope.dart';
import 'package:falnova/backend/services/fortune/gpt_service.dart';
import 'package:falnova/backend/services/astrology/transit_service.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'package:falnova/backend/models/astrology/transit_aspect.dart';
import 'package:logger/logger.dart';

final horoscopeServiceProvider = Provider((ref) => HoroscopeService(
      gptService: ref.watch(gptServiceProvider),
      transitService: ref.watch(transitServiceProvider),
    ));

class HoroscopeService {
  final GptService gptService;
  final TransitService transitService;
  final Map<String, Horoscope> _cache = {};
  final Duration _cacheDuration = const Duration(hours: 24);
  final _logger = Logger();

  HoroscopeService({
    required this.gptService,
    required this.transitService,
  });

  Future<Horoscope> getDailyHoroscope(String sign,
      {BirthChart? birthChart}) async {
    try {
      // Önbellekte varsa ve güncel ise, önbellekten döndür
      if (_cache.containsKey(sign)) {
        final cachedHoroscope = _cache[sign]!;
        if (DateTime.now().difference(cachedHoroscope.date) < _cacheDuration) {
          return cachedHoroscope;
        }
      }

      // Transit açıları hesapla
      final transitAspects = birthChart != null
          ? await transitService.calculateTransits(birthChart)
          : [];

      // Şanslı saatleri hesapla
      final luckyHours = _calculateLuckyHours(sign);

      // Öne çıkan noktaları hazırla
      final highlights = _prepareHighlights(transitAspects);

      // GPT prompt'unu hazırla
      final prompt =
          '''Sen bir astrologsun. $sign burcu için günlük yorum yapacaksın.
      ${transitAspects.isNotEmpty ? 'Şu transit açılar mevcut:\n${transitAspects.map((t) => t.interpretation).join('\n')}' : ''}
      
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

      final List<TransitAspect> typedTransitAspects =
          transitAspects.map((aspect) => aspect as TransitAspect).toList();

      final horoscope = Horoscope(
        sign: sign,
        dailyHoroscope: dailyHoroscope.trim(),
        date: DateTime.now(),
        scores: scores,
        luckNumber: luckNumber,
        luckColor: luckColor,
        transitAspects: typedTransitAspects,
        luckyHours: luckyHours,
        highlights: highlights,
      );

      // Önbelleğe kaydet
      _cache[sign] = horoscope;

      return horoscope;
    } catch (e) {
      _logger.e('Günlük burç yorumu alınırken hata oluştu', error: e);
      rethrow;
    }
  }

  List<String> _calculateLuckyHours(String sign) {
    final now = DateTime.now();
    final random =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final hours = <String>[];

    // Her burç için günde 3 şanslı saat
    for (var i = 0; i < 3; i++) {
      final hour = (random + sign.hashCode + i) % 24;
      hours.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return hours..sort();
  }

  List<String> _prepareHighlights(List<dynamic> aspects) {
    final highlights = <String>[];

    for (final dynamic aspect in aspects) {
      if (aspect is TransitAspect) {
        if (aspect.aspectType == 'Conjunction' ||
            aspect.aspectType == 'Opposition') {
          highlights.add(aspect.interpretation);
        }
      }
    }

    return highlights;
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

  // Önbelleği temizle
  void clearCache() {
    _cache.clear();
  }
}
