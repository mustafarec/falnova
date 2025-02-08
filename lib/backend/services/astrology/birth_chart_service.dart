import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'sweph_helper.dart';

part 'birth_chart_service.g.dart';

@riverpod
class BirthChartService extends _$BirthChartService {
  final _swephHelper = getSwephHelper();

  @override
  Future<BirthChart> build() async {
    await _swephHelper.init();
    return _calculateBirthChart(
      userId: 'default',
      birthDate: DateTime.now(),
      birthPlace: 'İstanbul',
      latitude: 41.0082,
      longitude: 28.9784,
    );
  }

  Future<BirthChart> calculateBirthChart({
    required String userId,
    required DateTime birthDate,
    required String birthPlace,
    required double latitude,
    required double longitude,
  }) async {
    await _swephHelper.init();
    return _calculateBirthChart(
      userId: userId,
      birthDate: birthDate,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<BirthChart> _calculateBirthChart({
    required String userId,
    required DateTime birthDate,
    required String birthPlace,
    required double latitude,
    required double longitude,
  }) async {
    final julianDay = _swephHelper.getJulianDay(birthDate);

    final planets = await _calculatePlanets(julianDay, latitude, longitude);
    final houses = await _calculateHouses(julianDay, latitude, longitude);
    final aspects = _calculateAspects(planets);

    return BirthChart(
      userId: userId,
      birthDate: birthDate,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      planets: planets,
      houses: Map.fromEntries(
        houses.asMap().entries.map(
              (e) => MapEntry('Ev ${e.key + 1}', e.value),
            ),
      ),
      aspects: Map.fromEntries(
        aspects.map((a) => MapEntry(a.planet1, [a])),
      ),
    );
  }

  Future<Map<String, PlanetPosition>> _calculatePlanets(
    double julianDay,
    double latitude,
    double longitude,
  ) async {
    final Map<String, PlanetPosition> planets = {};

    for (final planet in _swephHelper.planets) {
      final position = await _swephHelper.calculatePlanetPosition(
        planet,
        julianDay,
        latitude,
        longitude,
      );

      final sign = _getZodiacSign(position['longitude']!);
      final house = _getHouse(position['longitude']!);

      planets[planet] = PlanetPosition(
        sign: sign,
        degree: position['longitude']!,
        isRetrograde: position['isRetrograde']! > 0,
        house: house,
      );
    }

    return planets;
  }

  Future<List<HouseSystem>> _calculateHouses(
    double julianDay,
    double latitude,
    double longitude,
  ) async {
    final List<HouseSystem> houses = [];
    final cusps = await _swephHelper.calculateHouses(
      julianDay,
      latitude,
      longitude,
    );

    for (var i = 0; i < 12; i++) {
      final sign = _getZodiacSign(cusps[i]);
      houses.add(HouseSystem(
        sign: sign,
        degree: cusps[i],
        planets: [], // Initially empty, will be filled later
      ));
    }

    return houses;
  }

  List<Aspect> _calculateAspects(Map<String, PlanetPosition> planets) {
    final List<Aspect> aspects = [];
    final planetList = planets.keys.toList();

    for (var i = 0; i < planetList.length; i++) {
      for (var j = i + 1; j < planetList.length; j++) {
        final planet1 = planetList[i];
        final planet2 = planetList[j];
        final degree1 = planets[planet1]!.degree;
        final degree2 = planets[planet2]!.degree;

        final aspectType = _getAspectType(degree1, degree2);
        if (aspectType != null) {
          final orb = _calculateOrb(degree1, degree2, aspectType);
          final isApplying = _isAspectApplying(
            planets[planet1]!,
            planets[planet2]!,
            aspectType,
          );

          aspects.add(Aspect(
            planet1: planet1,
            planet2: planet2,
            aspectType: aspectType,
            orb: orb,
            isApplying: isApplying,
          ));
        }
      }
    }

    return aspects;
  }

  bool _isAspectApplying(
    PlanetPosition planet1,
    PlanetPosition planet2,
    String aspectType,
  ) {
    final angle = (planet1.degree - planet2.degree).abs() % 360;
    final targetAngle = {
      'conjunction': 0.0,
      'sextile': 60.0,
      'square': 90.0,
      'trine': 120.0,
      'opposition': 180.0,
    }[aspectType]!;

    final currentOrb = (angle - targetAngle).abs();
    final futureOrb = ((planet1.degree + 1) - (planet2.degree + 1)).abs() % 360;

    return futureOrb < currentOrb;
  }

  String _getZodiacSign(double longitude) {
    final signIndex = (longitude / 30).floor() % 12;
    const signs = [
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
      'Balık',
    ];
    return signs[signIndex];
  }

  int _getHouse(double longitude) {
    return ((longitude / 30).floor() % 12) + 1;
  }

  String? _getAspectType(double degree1, double degree2) {
    final angle = (degree1 - degree2).abs() % 360;
    const orb = 8.0; // Maksimum orb değeri

    if (_isWithinOrb(angle, 0, orb)) return 'conjunction';
    if (_isWithinOrb(angle, 60, orb)) return 'sextile';
    if (_isWithinOrb(angle, 90, orb)) return 'square';
    if (_isWithinOrb(angle, 120, orb)) return 'trine';
    if (_isWithinOrb(angle, 180, orb)) return 'opposition';

    return null;
  }

  bool _isWithinOrb(double angle, double aspectAngle, double orb) {
    final diff = (angle - aspectAngle).abs();
    return diff <= orb || (360 - diff) <= orb;
  }

  double _calculateOrb(double degree1, double degree2, String aspectType) {
    final angle = (degree1 - degree2).abs() % 360;
    final aspectAngles = {
      'conjunction': 0.0,
      'sextile': 60.0,
      'square': 90.0,
      'trine': 120.0,
      'opposition': 180.0,
    };
    final targetAngle = aspectAngles[aspectType]!;
    final orb = (angle - targetAngle).abs();
    return orb <= 180 ? orb : 360 - orb;
  }
}
