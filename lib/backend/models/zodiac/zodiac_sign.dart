import 'package:freezed_annotation/freezed_annotation.dart';

part 'zodiac_sign.freezed.dart';
part 'zodiac_sign.g.dart';

@freezed
class ZodiacSign with _$ZodiacSign {
  const factory ZodiacSign({
    required String name,
    required String element,
    required String symbol,
    required int startMonth,
    required int startDay,
    required int endMonth,
    required int endDay,
    required String characteristics,
    required String planet,
    required String quality,
    @Default({}) Map<String, double> compatibility,
    @Default([]) List<String> positiveTraits,
    @Default([]) List<String> negativeTraits,
    @Default('') String luckyDay,
    @Default('') String luckyNumber,
    @Default('') String luckyColor,
  }) = _ZodiacSign;

  factory ZodiacSign.fromJson(Map<String, dynamic> json) =>
      _$ZodiacSignFromJson(json);

  static List<ZodiacSign> get allSigns => [
        const ZodiacSign(
          name: 'Koç',
          element: 'Ateş',
          symbol: '♈',
          startMonth: 3,
          startDay: 21,
          endMonth: 4,
          endDay: 19,
          characteristics: 'Lider, enerjik, cesur',
          planet: 'Mars',
          quality: 'Öncü',
          positiveTraits: ['Cesur', 'Enerjik', 'Lider ruhlu', 'Dinamik'],
          negativeTraits: ['Sabırsız', 'Agresif', 'Bencil'],
          luckyDay: 'Salı',
          luckyNumber: '9',
          luckyColor: 'Kırmızı',
          compatibility: {
            'Aslan': 0.9,
            'Yay': 0.9,
            'İkizler': 0.8,
            'Terazi': 0.8,
            'Kova': 0.7,
          },
        ),
        const ZodiacSign(
          name: 'Boğa',
          element: 'Toprak',
          symbol: '♉',
          startMonth: 4,
          startDay: 20,
          endMonth: 5,
          endDay: 20,
          characteristics: 'Kararlı, güvenilir, sabırlı',
          planet: 'Venüs',
          quality: 'Sabit',
        ),
        const ZodiacSign(
          name: 'İkizler',
          element: 'Hava',
          symbol: '♊',
          startMonth: 5,
          startDay: 21,
          endMonth: 6,
          endDay: 20,
          characteristics: 'İletişimci, meraklı, uyumlu',
          planet: 'Merkür',
          quality: 'Değişken',
        ),
        const ZodiacSign(
          name: 'Yengeç',
          element: 'Su',
          symbol: '♋',
          startMonth: 6,
          startDay: 21,
          endMonth: 7,
          endDay: 22,
          characteristics: 'Duygusal, koruyucu, sezgisel',
          planet: 'Ay',
          quality: 'Öncü',
        ),
        const ZodiacSign(
          name: 'Aslan',
          element: 'Ateş',
          symbol: '♌',
          startMonth: 7,
          startDay: 23,
          endMonth: 8,
          endDay: 22,
          characteristics: 'Yaratıcı, cömert, neşeli',
          planet: 'Güneş',
          quality: 'Sabit',
        ),
        const ZodiacSign(
          name: 'Başak',
          element: 'Toprak',
          symbol: '♍',
          startMonth: 8,
          startDay: 23,
          endMonth: 9,
          endDay: 22,
          characteristics: 'Analitik, çalışkan, mükemmeliyetçi',
          planet: 'Merkür',
          quality: 'Değişken',
        ),
        const ZodiacSign(
          name: 'Terazi',
          element: 'Hava',
          symbol: '♎',
          startMonth: 9,
          startDay: 23,
          endMonth: 10,
          endDay: 22,
          characteristics: 'Diplomatik, adil, uyumlu',
          planet: 'Venüs',
          quality: 'Öncü',
        ),
        const ZodiacSign(
          name: 'Akrep',
          element: 'Su',
          symbol: '♏',
          startMonth: 10,
          startDay: 23,
          endMonth: 11,
          endDay: 21,
          characteristics: 'Tutkulu, kararlı, güçlü',
          planet: 'Mars/Plüton',
          quality: 'Sabit',
        ),
        const ZodiacSign(
          name: 'Yay',
          element: 'Ateş',
          symbol: '♐',
          startMonth: 11,
          startDay: 22,
          endMonth: 12,
          endDay: 21,
          characteristics: 'Maceracı, iyimser, özgür',
          planet: 'Jüpiter',
          quality: 'Değişken',
        ),
        const ZodiacSign(
          name: 'Oğlak',
          element: 'Toprak',
          symbol: '♑',
          startMonth: 12,
          startDay: 22,
          endMonth: 1,
          endDay: 19,
          characteristics: 'Disiplinli, sorumlu, geleneksel',
          planet: 'Satürn',
          quality: 'Öncü',
        ),
        const ZodiacSign(
          name: 'Kova',
          element: 'Hava',
          symbol: '♒',
          startMonth: 1,
          startDay: 20,
          endMonth: 2,
          endDay: 18,
          characteristics: 'Yenilikçi, bağımsız, insancıl',
          planet: 'Uranüs/Satürn',
          quality: 'Sabit',
        ),
        const ZodiacSign(
          name: 'Balık',
          element: 'Su',
          symbol: '♓',
          startMonth: 2,
          startDay: 19,
          endMonth: 3,
          endDay: 20,
          characteristics: 'Sezgisel, sanatsal, şefkatli',
          planet: 'Neptün/Jüpiter',
          quality: 'Değişken',
        ),
      ];
}
