import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sweph/sweph.dart';
import 'package:logger/logger.dart';

part 'ascendant_service.g.dart';

@riverpod
class AscendantService extends _$AscendantService {
  final _logger = Logger();
  static bool _isInitialized = false;

  @override
  Future<Map<String, String>> build() async {
    return {};
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await Sweph.init();
        _isInitialized = true;
        _logger.i('Swiss Ephemeris başarıyla başlatıldı');
      } catch (e) {
        _logger.e('Swiss Ephemeris başlatılamadı', error: e);
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> calculateAscendant({
    required DateTime birthDate,
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
      final ascSign = _getZodiacSign((ascDegree / 30).floor());

      // Dekan hesaplama (her burç 3 dekana ayrılır)
      final decan = _calculateDecan(ascDegree);

      // Yönetici gezegen
      final ruler = _getRuler(ascSign);

      // Yönetici gezegenin pozisyonu
      final rulerPos = await _calculateRulerPosition(ruler, julianDay);

      return {
        'sign': ascSign,
        'degree': ascDegree,
        'decan': decan,
        'ruler': ruler,
        'ruler_position': rulerPos,
      };
    } catch (e) {
      _logger.e('Yükselen burç hesaplanırken hata oluştu', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> calculateMoonAscendant({
    required DateTime birthDate,
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

      // Ay'ın pozisyonunu hesapla
      final moonPos = Sweph.swe_calc_ut(
        julianDay,
        HeavenlyBody.SE_MOON,
        SwephFlag.SEFLG_SWIEPH,
      );

      // Ay'ın ekliptik boylamı
      final moonLongitude = moonPos.longitude;
      final moonSign = _getZodiacSign((moonLongitude / 30).floor());

      // Dekan hesaplama
      final decan = _calculateDecan(moonLongitude);

      // Yönetici gezegen
      final ruler = _getRuler(moonSign);

      // Yönetici gezegenin pozisyonu
      final rulerPos = await _calculateRulerPosition(ruler, julianDay);

      return {
        'sign': moonSign,
        'degree': moonLongitude,
        'decan': decan,
        'ruler': ruler,
        'ruler_position': rulerPos,
      };
    } catch (e) {
      _logger.e('Ay burcu hesaplanırken hata oluştu', error: e);
      rethrow;
    }
  }

  String _getZodiacSign(int index) {
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
    return signs[index % 12];
  }

  int _calculateDecan(double degree) {
    final signDegree = degree % 30;
    if (signDegree < 10) return 1;
    if (signDegree < 20) return 2;
    return 3;
  }

  String _getRuler(String sign) {
    final rulers = {
      'Koç': 'Mars',
      'Boğa': 'Venüs',
      'İkizler': 'Merkür',
      'Yengeç': 'Ay',
      'Aslan': 'Güneş',
      'Başak': 'Merkür',
      'Terazi': 'Venüs',
      'Akrep': 'Mars',
      'Yay': 'Jüpiter',
      'Oğlak': 'Satürn',
      'Kova': 'Satürn',
      'Balık': 'Jüpiter',
    };
    return rulers[sign] ?? '';
  }

  Future<Map<String, dynamic>> _calculateRulerPosition(
    String ruler,
    double julianDay,
  ) async {
    final heavenlyBodies = {
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

    final planetId = heavenlyBodies[ruler];
    if (planetId == null) return {};

    final position = Sweph.swe_calc_ut(
      julianDay,
      planetId,
      SwephFlag.SEFLG_SWIEPH,
    );

    return {
      'longitude': position.longitude,
      'latitude': position.latitude,
      'distance': position.distance,
      'speed': position.speedInLongitude,
      'sign': _getZodiacSign((position.longitude / 30).floor()),
      'isRetrograde': position.speedInLongitude < 0,
    };
  }

  String getDecanInterpretation(String sign, int decan) {
    switch (sign) {
      case 'Koç':
        switch (decan) {
          case 1:
            return 'İlk dekan Mars yönetiminde. Saf, direkt ve cesur bir yaklaşım.';
          case 2:
            return 'İkinci dekan Güneş yönetiminde. Liderlik ve yaratıcı ifade öne çıkar.';
          case 3:
            return 'Üçüncü dekan Jüpiter yönetiminde. Felsefi yaklaşım ve genişleme arzusu.';
        }
      case 'Boğa':
        switch (decan) {
          case 1:
            return 'İlk dekan Venüs yönetiminde. Güzellik ve değer odaklı yaklaşım.';
          case 2:
            return 'İkinci dekan Merkür yönetiminde. Pratik ve analitik düşünce.';
          case 3:
            return 'Üçüncü dekan Satürn yönetiminde. Kararlılık ve yapısal yaklaşım.';
        }
      case 'İkizler':
        switch (decan) {
          case 1:
            return 'İlk dekan Merkür yönetiminde. Merak ve iletişim ön planda.';
          case 2:
            return 'İkinci dekan Venüs yönetiminde. Sosyal ilişkiler ve uyum önemli.';
          case 3:
            return 'Üçüncü dekan Uranüs yönetiminde. Yenilikçi ve özgün fikirler.';
        }
      case 'Yengeç':
        switch (decan) {
          case 1:
            return 'İlk dekan Ay yönetiminde. Duygusal derinlik ve sezgisellik.';
          case 2:
            return 'İkinci dekan Plüton yönetiminde. Dönüşüm ve içsel güç.';
          case 3:
            return 'Üçüncü dekan Neptün yönetiminde. Ruhsal hassasiyet ve empati.';
        }
      case 'Aslan':
        switch (decan) {
          case 1:
            return 'İlk dekan Güneş yönetiminde. Güçlü benlik ve yaratıcılık.';
          case 2:
            return 'İkinci dekan Jüpiter yönetiminde. Cömertlik ve büyüme.';
          case 3:
            return 'Üçüncü dekan Mars yönetiminde. Dinamizm ve cesaret.';
        }
      case 'Başak':
        switch (decan) {
          case 1:
            return 'İlk dekan Merkür yönetiminde. Analitik düşünce ve detaycılık.';
          case 2:
            return 'İkinci dekan Satürn yönetiminde. Disiplin ve metodoloji.';
          case 3:
            return 'Üçüncü dekan Venüs yönetiminde. Hizmet ve uyum.';
        }
      case 'Terazi':
        switch (decan) {
          case 1:
            return 'İlk dekan Venüs yönetiminde. Denge ve estetik.';
          case 2:
            return 'İkinci dekan Uranüs yönetiminde. Özgürlük ve yenilik.';
          case 3:
            return 'Üçüncü dekan Merkür yönetiminde. İletişim ve diplomasi.';
        }
      case 'Akrep':
        switch (decan) {
          case 1:
            return 'İlk dekan Mars yönetiminde. Yoğun duygular ve tutku.';
          case 2:
            return 'İkinci dekan Neptün yönetiminde. Sezgisel güç ve gizem.';
          case 3:
            return 'Üçüncü dekan Plüton yönetiminde. Dönüşüm ve yenilenme.';
        }
      case 'Yay':
        switch (decan) {
          case 1:
            return 'İlk dekan Jüpiter yönetiminde. Genişleme ve iyimserlik.';
          case 2:
            return 'İkinci dekan Mars yönetiminde. Macera ve keşif.';
          case 3:
            return 'Üçüncü dekan Güneş yönetiminde. Vizyon ve liderlik.';
        }
      case 'Oğlak':
        switch (decan) {
          case 1:
            return 'İlk dekan Satürn yönetiminde. Disiplin ve sorumluluk.';
          case 2:
            return 'İkinci dekan Venüs yönetiminde. Pratik değerler ve başarı.';
          case 3:
            return 'Üçüncü dekan Merkür yönetiminde. Stratejik düşünce.';
        }
      case 'Kova':
        switch (decan) {
          case 1:
            return 'İlk dekan Uranüs yönetiminde. Özgünlük ve devrim.';
          case 2:
            return 'İkinci dekan Merkür yönetiminde. Entelektüel keşif.';
          case 3:
            return 'Üçüncü dekan Venüs yönetiminde. Sosyal idealler.';
        }
      case 'Balık':
        switch (decan) {
          case 1:
            return 'İlk dekan Neptün yönetiminde. Ruhsal hassasiyet ve sanat.';
          case 2:
            return 'İkinci dekan Ay yönetiminde. Duygusal derinlik ve sezgi.';
          case 3:
            return 'Üçüncü dekan Plüton yönetiminde. Ruhsal dönüşüm.';
        }
    }
    return 'Bilinmeyen dekan';
  }

  String getRulerInterpretation(String ruler, Map<String, dynamic> position) {
    final interpretation = StringBuffer();

    interpretation.writeln('$ruler yönetiminde:');

    // Yönetici gezegenin burcu
    interpretation.writeln(
        '${position['sign']} burcunda ${position['longitude'].toStringAsFixed(2)}°');

    // Retro durumu
    if (position['isRetrograde']) {
      interpretation.writeln('Retro harekette - içsel deneyimler öne çıkar');
    }

    // Hız durumu
    final speed = position['speed'];
    if (speed > 1.5) {
      interpretation.writeln('Hızlı hareket - olaylar hızlı gelişebilir');
    } else if (speed < 0.5) {
      interpretation.writeln('Yavaş hareket - süreçler daha uzun sürebilir');
    }

    return interpretation.toString();
  }
}
