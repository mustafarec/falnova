// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palm_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PalmReadingImpl _$$PalmReadingImplFromJson(Map<String, dynamic> json) =>
    _$PalmReadingImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String,
      lineCoordinates: (json['lineCoordinates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map(
                    (e) => const Vector2Converter().fromJson(e as List<double>))
                .toList()),
      ),
      interpretations: Map<String, String>.from(json['interpretations'] as Map),
      aiAnalysis: json['aiAnalysis'] as String?,
      isProcessed: json['isProcessed'] as bool? ?? false,
    );

Map<String, dynamic> _$$PalmReadingImplToJson(_$PalmReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'lineCoordinates': instance.lineCoordinates.map((k, e) =>
          MapEntry(k, e.map(const Vector2Converter().toJson).toList())),
      'interpretations': instance.interpretations,
      'aiAnalysis': instance.aiAnalysis,
      'isProcessed': instance.isProcessed,
    };
