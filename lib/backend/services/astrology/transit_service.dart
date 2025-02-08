import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/astrology/transit_aspect.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart'
    as birth_chart;
import 'package:sweph/sweph.dart';
import 'package:logger/logger.dart';
import 'package:falnova/backend/services/zodiac/io_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:falnova/backend/models/zodiac/zodiac_sign.dart';
import 'package:falnova/backend/models/astrology/planet.dart';

final transitServiceProvider = Provider((ref) => TransitService());

class TransitService {
  bool _isInitialized = false;
  final _logger = Logger();

  TransitService();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final ephemerisFiles = [
        'seas_18.se1',
        'semo_18.se1',
        'sepl_18.se1',
        'sefstars.txt',
        'seasnam.txt',
        'seorbel.txt',
        'seleapsec.txt'
      ];

      final appDir = await getApplicationSupportDirectory();
      final ephePath = '${appDir.path}/ephe';

      await initSweph(ephemerisFiles);
      Sweph.swe_set_ephe_path(ephePath);

      _isInitialized = true;
      _logger.i('Swiss Ephemeris başarıyla başlatıldı');
    } catch (e) {
      _logger.e('Swiss Ephemeris başlatılamadı', error: e);
      rethrow;
    }
  }

  Future<List<TransitAspect>> calculateTransits(
      birth_chart.BirthChart birthChart) async {
    try {
      await initialize();
      final aspects = <TransitAspect>[];
      final now = DateTime.now();

      // Transit gezegen pozisyonlarını hesapla
      final transitPositions = await _calculatePlanetPositions(now);

      // Natal gezegen pozisyonları
      final natalPositions = birthChart.planets;

      // Aspect açıları ve orb değerleri
      final aspectAngles = {
        'Conjunction': 0.0,
        'Sextile': 60.0,
        'Square': 90.0,
        'Trine': 120.0,
        'Opposition': 180.0,
      };

      // Her transit gezegen için natal gezegenlerle açıları kontrol et
      for (final transit in transitPositions.entries) {
        for (final natal in natalPositions.entries) {
          final transitDegree = _calculateTotalDegree(transit.value);
          final natalDegree = _calculateTotalDegree(natal.value);

          for (final aspect in aspectAngles.entries) {
            final orb = _calculateOrb(transitDegree, natalDegree, aspect.value);
            if (orb <= 2.0) {
              // Transit açıları için daha dar orb
              final interpretation = _getTransitInterpretation(
                transit.key,
                natal.key,
                aspect.key,
              );

              aspects.add(
                TransitAspect(
                  transitPlanet: transit.key,
                  sign: transit.value.sign,
                  degree: transit.value.degree,
                  isRetrograde: transit.value.isRetrograde,
                  aspectType: aspect.key,
                  interpretation: interpretation,
                  aspectsToNatal: [
                    NatalAspect(
                      natalPlanet: natal.key,
                      aspectType: aspect.key,
                      orb: orb,
                      isApplying: _isAspectApplying(transit.value, natal.value),
                      interpretation: interpretation,
                    ),
                  ],
                ),
              );
            }
          }
        }
      }

      return aspects;
    } catch (e) {
      _logger.e('Transit hesaplanırken hata oluştu', error: e);
      rethrow;
    }
  }

  Future<Map<String, birth_chart.PlanetPosition>> _calculatePlanetPositions(
    DateTime date,
  ) async {
    final julianDay = Sweph.swe_julday(
      date.year,
      date.month,
      date.day,
      date.hour + date.minute / 60,
      CalendarType.SE_GREG_CAL,
    );

    final planets = <String, birth_chart.PlanetPosition>{};
    final planetList = {
      'Güneş': HeavenlyBody.SE_SUN,
      'Ay': HeavenlyBody.SE_MOON,
      'Merkür': HeavenlyBody.SE_MERCURY,
      'Venüs': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jüpiter': HeavenlyBody.SE_JUPITER,
      'Satürn': HeavenlyBody.SE_SATURN,
      'Uranüs': HeavenlyBody.SE_URANUS,
      'Neptün': HeavenlyBody.SE_NEPTUNE,
      'Plüton': HeavenlyBody.SE_PLUTO,
    };

    for (final entry in planetList.entries) {
      final result = Sweph.swe_calc_ut(
        julianDay,
        entry.value,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
      );

      planets[entry.key] = birth_chart.PlanetPosition(
        sign: _getZodiacSign(result.longitude),
        degree: result.longitude % 30,
        isRetrograde: result.latitude < 0,
        house: 0,
      );
    }

    return planets;
  }

  double _calculateTotalDegree(birth_chart.PlanetPosition position) {
    final signs = [
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
    final signIndex = signs.indexOf(position.sign);
    return (signIndex * 30 + position.degree).toDouble();
  }

  double _calculateOrb(double degree1, double degree2, double aspectAngle) {
    var diff = (degree1 - degree2).abs();
    if (diff > 180) diff = 360 - diff;
    return (diff - aspectAngle).abs();
  }

  bool _isAspectApplying(
      birth_chart.PlanetPosition transit, birth_chart.PlanetPosition natal) {
    return transit.isRetrograde != natal.isRetrograde;
  }

  String _getZodiacSign(double longitude) {
    final signs = [
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
    final index = (longitude / 30).floor() % 12;
    return signs[index];
  }

  String _getTransitInterpretation(
    String transitPlanet,
    String natalPlanet,
    String aspectType,
  ) {
    final interpretation = StringBuffer();

    // Açı tipine göre temel yorum
    switch (aspectType) {
      case 'Conjunction':
        interpretation.write(
            '$transitPlanet transit gezegeniniz, natal $natalPlanet ile kavuşum yapıyor. ');
        interpretation.write('Bu güçlü bir birleşim enerjisi yaratıyor. ');
        break;
      case 'Opposition':
        interpretation.write(
            '$transitPlanet transit gezegeniniz, natal $natalPlanet ile karşıt açı yapıyor. ');
        interpretation.write(
            'Bu durum bazı gerginlikler ve farkındalıklar getirebilir. ');
        break;
      case 'Trine':
        interpretation.write(
            '$transitPlanet transit gezegeniniz, natal $natalPlanet ile üçgen açı yapıyor. ');
        interpretation
            .write('Bu uyumlu açı, fırsatlar ve kolaylıklar sağlayabilir. ');
        break;
      case 'Square':
        interpretation.write(
            '$transitPlanet transit gezegeniniz, natal $natalPlanet ile kare açı yapıyor. ');
        interpretation.write(
            'Bu zorlayıcı açı, değişim ve gelişim için itici güç olabilir. ');
        break;
      case 'Sextile':
        interpretation.write(
            '$transitPlanet transit gezegeniniz, natal $natalPlanet ile altmışlık açı yapıyor. ');
        interpretation
            .write('Bu destekleyici açı, olumlu fırsatlar sunabilir. ');
        break;
    }

    // Gezegenlere özel yorumlar
    if (transitPlanet == 'Güneş') {
      interpretation.write(
          'Güneş transitiyle birlikte kimliğiniz ve yaşam enerjiniz ön plana çıkıyor. ');
    } else if (transitPlanet == 'Ay') {
      interpretation.write(
          'Ay transitiyle duygusal dünyanız ve içsel ihtiyaçlarınız önem kazanıyor. ');
    } else if (transitPlanet == 'Merkür') {
      interpretation.write(
          'Merkür transitiyle iletişim ve düşünce süreçleriniz etkileniyor. ');
    } else if (transitPlanet == 'Venüs') {
      interpretation.write(
          'Venüs transitiyle ilişkiler ve değerler sisteminiz vurgulanıyor. ');
    } else if (transitPlanet == 'Mars') {
      interpretation.write(
          'Mars transitiyle motivasyon ve girişimcilik enerjiniz yükseliyor. ');
    }

    return interpretation.toString();
  }

  Future<List<TransitAspect>> getTransits({
    required DateTime date,
    required birth_chart.BirthChart? birthChart,
  }) async {
    try {
      await initialize();
      final transitPositions = await _calculatePlanetPositions(date);

      // Transit pozisyonlarını TransitAspect'e dönüştür
      final transitAspects = transitPositions.entries.map((entry) {
        final position = entry.value;
        return TransitAspect(
          transitPlanet: entry.key,
          sign: position.sign,
          degree: position.degree,
          isRetrograde: position.isRetrograde,
          aspectType: 'Transit',
          interpretation:
              '${entry.key} ${position.sign} burcunda ${position.degree.toStringAsFixed(1)}°',
        );
      }).toList();

      // Eğer doğum haritası varsa, natal karşılaştırmaları ekle
      if (birthChart != null) {
        final natalAspects = await calculateTransits(birthChart);
        final aspects = <TransitAspect>[];

        for (var transit in transitAspects) {
          final natalAspectsForPlanet = natalAspects
              .where((a) => a.transitPlanet == transit.transitPlanet)
              .expand((a) => a.aspectsToNatal)
              .toList();

          aspects.add(TransitAspect(
            transitPlanet: transit.transitPlanet,
            sign: transit.sign,
            degree: transit.degree,
            isRetrograde: transit.isRetrograde,
            aspectType: 'Transit',
            interpretation: transit.interpretation,
            aspectsToNatal: natalAspectsForPlanet,
          ));
        }
        return aspects;
      }

      return transitAspects;
    } catch (e) {
      _logger.e('Transit hesaplanırken hata oluştu', error: e);
      rethrow;
    }
  }
}

class TransitPosition {
  final Planet planet;
  final ZodiacSign sign;
  final double degree;
  final bool isRetrograde;

  TransitPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.isRetrograde,
  });

  @override
  String toString() =>
      '${planet.name} ${sign.name}\'da ${degree.toStringAsFixed(1)}° ${isRetrograde ? "(R)" : ""}';
}
