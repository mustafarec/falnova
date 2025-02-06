import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/astrology/horoscope.dart';
import 'package:falnova/backend/services/astrology/horoscope_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final horoscopeRepositoryProvider =
    StateNotifierProvider<HoroscopeRepository, List<Horoscope>>((ref) {
  final horoscopeService = ref.watch(horoscopeServiceProvider);
  return HoroscopeRepository(horoscopeService: horoscopeService);
});

class HoroscopeRepository extends StateNotifier<List<Horoscope>> {
  final HoroscopeService horoscopeService;
  final _supabase = Supabase.instance.client;

  HoroscopeRepository({
    required this.horoscopeService,
  }) : super([]);

  Future<Horoscope> getDailyHoroscope(String sign) async {
    try {
      // Önce cache'den kontrol et
      final cachedHoroscope = state.firstWhere(
        (h) =>
            h.sign == sign &&
            h.date.year == DateTime.now().year &&
            h.date.month == DateTime.now().month &&
            h.date.day == DateTime.now().day,
        orElse: () => throw Exception('not_found'),
      );

      return cachedHoroscope;
    } catch (_) {
      // Cache'de yoksa yeni yorum al
      final horoscope = await horoscopeService.getDailyHoroscope(sign);

      // Supabase'e kaydet
      await _supabase.from('horoscopes').insert({
        'sign': horoscope.sign,
        'daily_horoscope': horoscope.dailyHoroscope,
        'date': horoscope.date.toIso8601String(),
        'scores': horoscope.scores,
        'luck_number': horoscope.luckNumber,
        'luck_color': horoscope.luckColor,
        'is_premium': horoscope.isPremium,
      });

      // Cache'e ekle
      state = [...state, horoscope];

      return horoscope;
    }
  }

  Future<List<Horoscope>> getHoroscopeHistory(String sign) async {
    try {
      final response = await _supabase
          .from('horoscopes')
          .select()
          .eq('sign', sign)
          .order('date', ascending: false);

      final horoscopes = (response as List).map((data) {
        final map = data as Map<String, dynamic>;
        return Horoscope(
          sign: map['sign'] as String,
          dailyHoroscope: map['daily_horoscope'] as String,
          date: DateTime.parse(map['date'] as String),
          scores: Map<String, int>.from(map['scores'] as Map),
          luckNumber: map['luck_number'] as String?,
          luckColor: map['luck_color'] as String?,
          isPremium: map['is_premium'] as bool? ?? false,
        );
      }).toList();

      state = horoscopes;
      return horoscopes;
    } catch (e) {
      throw Exception('Burç geçmişi alınırken bir hata oluştu: $e');
    }
  }
}
