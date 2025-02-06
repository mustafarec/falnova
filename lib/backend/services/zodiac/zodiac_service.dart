import 'package:falnova/backend/models/zodiac/zodiac_sign.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sweph/sweph.dart';
import 'web_helper.dart' if (dart.library.ffi) 'io_helper.dart';

part 'zodiac_service.g.dart';

@riverpod
ZodiacService zodiacService(Ref ref) => ZodiacService();

// Yükselen burç provider'ı
@riverpod
Future<String> ascendantSign(
  AscendantSignRef ref, {
  required DateTime birthDate,
  required double latitude,
  required double longitude,
}) async {
  final zodiacService = ref.watch(zodiacServiceProvider);
  return zodiacService.calculateAscendant(
    birthDate,
    latitude: latitude,
    longitude: longitude,
  );
}

// Ay burcu provider'ı
@riverpod
Future<String> moonSign(
  MoonSignRef ref, {
  required DateTime birthDate,
}) async {
  final zodiacService = ref.watch(zodiacServiceProvider);
  return zodiacService.calculateMoonSign(birthDate);
}

class ZodiacService {
  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await initSweph([
          'seas_18.se1',
          'sefstars.txt',
          'seasnam.txt',
        ]);
        _isInitialized = true;
      } catch (e) {
        print('Swiss Ephemeris başlatılamadı: $e');
        rethrow;
      }
    }
  }

  /// Verilen doğum tarihine göre güneş burcunu hesaplar
  ZodiacSign calculateSunSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    for (final sign in ZodiacSign.allSigns) {
      // Aynı ay içindeki burç
      if (sign.startMonth == month && day >= sign.startDay) {
        return sign;
      }
      // Ay geçişli burç
      if (sign.endMonth == month && day <= sign.endDay) {
        return sign;
      }
      // Yılbaşı geçişli burç (Oğlak)
      if (sign.startMonth == 12 && month == 12 && day >= sign.startDay) {
        return sign;
      }
      if (sign.endMonth == 1 && month == 1 && day <= sign.endDay) {
        return sign;
      }
    }

    throw Exception('Geçersiz tarih');
  }

  /// Verilen doğum tarihi ve konuma göre yükselen burcu hesaplar
  Future<String> calculateAscendant(
    DateTime birthDate, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      await initialize();

      // Julian Gün hesaplama
      final julianDay = Sweph.swe_julday(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        birthDate.hour + birthDate.minute / 60.0,
        CalendarType.SE_GREG_CAL,
      );

      // Yükselen burç hesaplama (Placidus ev sistemi)
      final houses = Sweph.swe_houses_ex2(
        julianDay,
        SwephFlag.SEFLG_TROPICAL,
        latitude,
        longitude,
        Hsys.P, // Placidus ev sistemi
      );

      // Yükselen burç derecesi (1. ev başlangıcı)
      final ascDegree = houses.cusps[0];
      return _getZodiacSign((ascDegree / 30).floor());
    } catch (e) {
      return _calculateSimpleAscendant(birthDate);
    }
  }

  /// Verilen doğum tarihine göre ay burcunu hesaplar
  Future<String> calculateMoonSign(DateTime birthDate) async {
    try {
      await initialize();

      // Julian Gün hesaplama
      final julianDay = Sweph.swe_julday(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        birthDate.hour + birthDate.minute / 60.0,
        CalendarType.SE_GREG_CAL,
      );

      // Ay'ın pozisyonunu hesaplama
      final moonPos = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_MOON,
        SwephFlag.SEFLG_SWIEPH,
      );

      // Ay'ın ekliptik boylamı
      final moonLongitude = moonPos.longitude;
      return _getZodiacSign((moonLongitude / 30).floor());
    } catch (e) {
      return _calculateSimpleMoonSign(birthDate);
    }
  }

  String _getZodiacSign(int index) {
    final List<String> signs = [
      'Koç',
      'Boğa',
      'İkizler',
      'Yengeç',
      'Aslan',
      'Başak',
      'Terazi',
      'Akrep',
      'Yay',
      'Oğlak',
      'Kova',
      'Balık'
    ];
    return signs[index % 12];
  }

  String _calculateSimpleAscendant(DateTime birthDate) {
    final int hour = birthDate.hour;
    final int month = birthDate.month;
    final int index = ((hour * 30 + month * 30) ~/ 360) % 12;
    return _getZodiacSign(index);
  }

  String _calculateSimpleMoonSign(DateTime birthDate) {
    final int dayOfYear = int.parse(DateFormat('D').format(birthDate));
    final int index = ((dayOfYear * 12) ~/ 365) % 12;
    return _getZodiacSign(index);
  }
}
