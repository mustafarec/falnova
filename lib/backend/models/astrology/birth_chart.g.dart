// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birth_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BirthChartImpl _$$BirthChartImplFromJson(Map<String, dynamic> json) =>
    _$BirthChartImpl(
      userId: json['userId'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthPlace: json['birthPlace'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      planets: (json['planets'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, PlanetPosition.fromJson(e as Map<String, dynamic>)),
      ),
      houses: (json['houses'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, HouseSystem.fromJson(e as Map<String, dynamic>)),
      ),
      aspects: (json['aspects'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => Aspect.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$$BirthChartImplToJson(_$BirthChartImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'birthDate': instance.birthDate.toIso8601String(),
      'birthPlace': instance.birthPlace,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'planets': instance.planets,
      'houses': instance.houses,
      'aspects': instance.aspects,
    };

_$PlanetPositionImpl _$$PlanetPositionImplFromJson(Map<String, dynamic> json) =>
    _$PlanetPositionImpl(
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      isRetrograde: json['isRetrograde'] as bool,
      house: (json['house'] as num).toInt(),
    );

Map<String, dynamic> _$$PlanetPositionImplToJson(
        _$PlanetPositionImpl instance) =>
    <String, dynamic>{
      'sign': instance.sign,
      'degree': instance.degree,
      'isRetrograde': instance.isRetrograde,
      'house': instance.house,
    };

_$HouseSystemImpl _$$HouseSystemImplFromJson(Map<String, dynamic> json) =>
    _$HouseSystemImpl(
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      planets:
          (json['planets'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$HouseSystemImplToJson(_$HouseSystemImpl instance) =>
    <String, dynamic>{
      'sign': instance.sign,
      'degree': instance.degree,
      'planets': instance.planets,
    };

_$AspectImpl _$$AspectImplFromJson(Map<String, dynamic> json) => _$AspectImpl(
      planet1: json['planet1'] as String,
      planet2: json['planet2'] as String,
      aspectType: json['aspectType'] as String,
      orb: (json['orb'] as num).toDouble(),
      isApplying: json['isApplying'] as bool,
    );

Map<String, dynamic> _$$AspectImplToJson(_$AspectImpl instance) =>
    <String, dynamic>{
      'planet1': instance.planet1,
      'planet2': instance.planet2,
      'aspectType': instance.aspectType,
      'orb': instance.orb,
      'isApplying': instance.isApplying,
    };
