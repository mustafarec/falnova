import 'package:falnova/backend/models/astrology/planet.dart';

class EphemerisService {
  Future<PlanetPosition> calculatePlanetPosition({
    required Planet planet,
    required DateTime date,
  }) async {
    // TODO: Swiss Ephemeris entegrasyonu yapılacak
    // Şimdilik test verileri döndürüyoruz
    return PlanetPosition(
      longitude: _getTestLongitude(planet),
      latitude: 0,
      distance: 1,
      speed: _getTestSpeed(planet),
      isRetrograde: _isTestRetrograde(planet),
    );
  }

  double _getTestLongitude(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return 15; // Koç'ta
      case Planet.moon:
        return 95; // Yengeç'te
      case Planet.mercury:
        return 340; // Balık'ta
      case Planet.venus:
        return 45; // Boğa'da
      case Planet.mars:
        return 180; // Terazi'de
      case Planet.jupiter:
        return 270; // Oğlak'ta
      case Planet.saturn:
        return 300; // Kova'da
      case Planet.uranus:
        return 30; // Boğa'da
      case Planet.neptune:
        return 320; // Balık'ta
      case Planet.pluto:
        return 270; // Oğlak'ta
    }
  }

  double _getTestSpeed(Planet planet) {
    switch (planet) {
      case Planet.moon:
        return 13.0;
      case Planet.mercury:
        return -0.5; // Retro
      case Planet.venus:
        return 1.0;
      default:
        return 1.0;
    }
  }

  bool _isTestRetrograde(Planet planet) {
    return planet == Planet.mercury || planet == Planet.mars;
  }
}

class PlanetPosition {
  final double longitude;
  final double latitude;
  final double distance;
  final double speed;
  final bool isRetrograde;

  PlanetPosition({
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speed,
    required this.isRetrograde,
  });
}
