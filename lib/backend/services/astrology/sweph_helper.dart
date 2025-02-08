import 'package:sweph/sweph.dart';

class SwephHelper {
  static final SwephHelper _instance = SwephHelper._internal();
  factory SwephHelper() => _instance;
  SwephHelper._internal();

  static bool _isInitialized = false;

  final List<String> planets = [
    'Güneş',
    'Ay',
    'Merkür',
    'Venüs',
    'Mars',
    'Jüpiter',
    'Satürn',
    'Uranüs',
    'Neptün',
    'Plüton',
  ];

  final Map<String, HeavenlyBody> _planetIds = {
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

  Future<void> init() async {
    if (!_isInitialized) {
      await Sweph.init();
      _isInitialized = true;
    }
  }

  double getJulianDay(DateTime dateTime) {
    return Sweph.swe_julday(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour + dateTime.minute / 60,
      CalendarType.SE_GREG_CAL,
    );
  }

  Future<Map<String, double>> calculatePlanetPosition(
    String planet,
    double julianDay,
    double latitude,
    double longitude,
  ) async {
    final planetId = _planetIds[planet];
    if (planetId == null) {
      throw Exception('Geçersiz gezegen: $planet');
    }

    final result = Sweph.swe_calc_ut(
      julianDay,
      planetId,
      SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
    );

    final isRetrograde = result.speedInLongitude < 0;

    return {
      'longitude': result.longitude,
      'latitude': result.latitude,
      'distance': result.distance,
      'speed': result.speedInLongitude,
      'isRetrograde': isRetrograde ? 1.0 : 0.0,
    };
  }

  Future<List<double>> calculateHouses(
    double julianDay,
    double latitude,
    double longitude,
  ) async {
    final houses = Sweph.swe_houses(
      julianDay,
      latitude,
      longitude,
      Hsys.P, // Placidus ev sistemi
    );

    return houses.cusps;
  }
}

SwephHelper getSwephHelper() => SwephHelper();
