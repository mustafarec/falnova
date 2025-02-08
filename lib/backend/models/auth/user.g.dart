// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthPlace: json['birthPlace'] as String,
      birthLat: (json['birthLat'] as num).toDouble(),
      birthLng: (json['birthLng'] as num).toDouble(),
      birthChart: json['birthChart'] == null
          ? null
          : BirthChart.fromJson(json['birthChart'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'birthDate': instance.birthDate.toIso8601String(),
      'birthPlace': instance.birthPlace,
      'birthLat': instance.birthLat,
      'birthLng': instance.birthLng,
      'birthChart': instance.birthChart,
    };
