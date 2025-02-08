// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transit_aspect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransitAspectImpl _$$TransitAspectImplFromJson(Map<String, dynamic> json) =>
    _$TransitAspectImpl(
      transitPlanet: json['transitPlanet'] as String,
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      isRetrograde: json['isRetrograde'] as bool,
      aspectType: json['aspectType'] as String,
      interpretation: json['interpretation'] as String,
      natalPlanet: json['natalPlanet'] as String?,
      orb: (json['orb'] as num?)?.toDouble(),
      aspectsToNatal: (json['aspectsToNatal'] as List<dynamic>?)
              ?.map((e) => NatalAspect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TransitAspectImplToJson(_$TransitAspectImpl instance) =>
    <String, dynamic>{
      'transitPlanet': instance.transitPlanet,
      'sign': instance.sign,
      'degree': instance.degree,
      'isRetrograde': instance.isRetrograde,
      'aspectType': instance.aspectType,
      'interpretation': instance.interpretation,
      'natalPlanet': instance.natalPlanet,
      'orb': instance.orb,
      'aspectsToNatal': instance.aspectsToNatal,
    };

_$NatalAspectImpl _$$NatalAspectImplFromJson(Map<String, dynamic> json) =>
    _$NatalAspectImpl(
      natalPlanet: json['natalPlanet'] as String,
      aspectType: json['aspectType'] as String,
      orb: (json['orb'] as num).toDouble(),
      isApplying: json['isApplying'] as bool,
      interpretation: json['interpretation'] as String,
    );

Map<String, dynamic> _$$NatalAspectImplToJson(_$NatalAspectImpl instance) =>
    <String, dynamic>{
      'natalPlanet': instance.natalPlanet,
      'aspectType': instance.aspectType,
      'orb': instance.orb,
      'isApplying': instance.isApplying,
      'interpretation': instance.interpretation,
    };
