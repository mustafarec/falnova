// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horoscope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HoroscopeImpl _$$HoroscopeImplFromJson(Map<String, dynamic> json) =>
    _$HoroscopeImpl(
      sign: json['sign'] as String,
      dailyHoroscope: json['dailyHoroscope'] as String,
      date: DateTime.parse(json['date'] as String),
      scores: Map<String, int>.from(json['scores'] as Map),
      luckNumber: json['luckNumber'] as String?,
      luckColor: json['luckColor'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
    );

Map<String, dynamic> _$$HoroscopeImplToJson(_$HoroscopeImpl instance) =>
    <String, dynamic>{
      'sign': instance.sign,
      'dailyHoroscope': instance.dailyHoroscope,
      'date': instance.date.toIso8601String(),
      'scores': instance.scores,
      'luckNumber': instance.luckNumber,
      'luckColor': instance.luckColor,
      'isPremium': instance.isPremium,
    };
