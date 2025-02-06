// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      id: json['id'] as String,
      totalReadings: (json['total_readings'] as num?)?.toInt() ?? 0,
      premiumReadings: (json['premium_readings'] as num?)?.toInt() ?? 0,
      standardReadings: (json['standard_readings'] as num?)?.toInt() ?? 0,
      lastReadingDate: json['last_reading_date'] == null
          ? null
          : DateTime.parse(json['last_reading_date'] as String),
      favoriteFortuneTeller: json['favorite_fortune_teller'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'id': instance.id,
      'total_readings': instance.totalReadings,
      'premium_readings': instance.premiumReadings,
      'standard_readings': instance.standardReadings,
      'last_reading_date': instance.lastReadingDate?.toIso8601String(),
      'favorite_fortune_teller': instance.favoriteFortuneTeller,
      'average_rating': instance.averageRating,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
