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
      compatibility: (json['compatibility'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      positiveTraits: (json['positiveTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      negativeTraits: (json['negativeTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      luckyDay: json['luckyDay'] as String? ?? '',
      luckyNumber: json['luckyNumber'] as String? ?? '',
      luckyColor: json['luckyColor'] as String? ?? '',
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
      'compatibility': instance.compatibility,
      'positiveTraits': instance.positiveTraits,
      'negativeTraits': instance.negativeTraits,
      'luckyDay': instance.luckyDay,
      'luckyNumber': instance.luckyNumber,
      'luckyColor': instance.luckyColor,
    };
