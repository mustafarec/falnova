// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zodiac_sign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ZodiacSignImpl _$$ZodiacSignImplFromJson(Map<String, dynamic> json) =>
    _$ZodiacSignImpl(
      name: json['name'] as String,
      element: json['element'] as String,
      symbol: json['symbol'] as String,
      startMonth: (json['startMonth'] as num).toInt(),
      startDay: (json['startDay'] as num).toInt(),
      endMonth: (json['endMonth'] as num).toInt(),
      endDay: (json['endDay'] as num).toInt(),
      characteristics: json['characteristics'] as String,
      planet: json['planet'] as String,
      quality: json['quality'] as String,
    );

Map<String, dynamic> _$$ZodiacSignImplToJson(_$ZodiacSignImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'element': instance.element,
      'symbol': instance.symbol,
      'startMonth': instance.startMonth,
      'startDay': instance.startDay,
      'endMonth': instance.endMonth,
      'endDay': instance.endDay,
      'characteristics': instance.characteristics,
      'planet': instance.planet,
      'quality': instance.quality,
    };
