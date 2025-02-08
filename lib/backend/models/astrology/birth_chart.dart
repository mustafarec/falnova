import 'package:freezed_annotation/freezed_annotation.dart';


part 'birth_chart.freezed.dart';
part 'birth_chart.g.dart';

@freezed
class BirthChart with _$BirthChart {
  const factory BirthChart({
    required String userId,
    required DateTime birthDate,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required Map<String, PlanetPosition> planets,
    required Map<String, HouseSystem> houses,
    required Map<String, List<Aspect>> aspects,
  }) = _BirthChart;

  factory BirthChart.fromJson(Map<String, dynamic> json) =>
      _$BirthChartFromJson(json);
}

@freezed
class PlanetPosition with _$PlanetPosition {
  const factory PlanetPosition({
    required String sign,
    required double degree,
    required bool isRetrograde,
    required int house,
  }) = _PlanetPosition;

  factory PlanetPosition.fromJson(Map<String, dynamic> json) =>
      _$PlanetPositionFromJson(json);
}

@freezed
class HouseSystem with _$HouseSystem {
  const factory HouseSystem({
    required String sign,
    required double degree,
    required List<String> planets,
  }) = _HouseSystem;

  factory HouseSystem.fromJson(Map<String, dynamic> json) =>
      _$HouseSystemFromJson(json);
}

@freezed
class Aspect with _$Aspect {
  const factory Aspect({
    required String planet1,
    required String planet2,
    required String aspectType,
    required double orb,
    required bool isApplying,
  }) = _Aspect;

  factory Aspect.fromJson(Map<String, dynamic> json) => _$AspectFromJson(json);
}
