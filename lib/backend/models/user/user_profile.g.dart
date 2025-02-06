// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
      birthCity: json['birth_city'] as String?,
      gender: json['gender'] as String?,
      zodiacSign: json['zodiac_sign'] as String?,
      risingSign: json['rising_sign'] as String?,
      moonSign: json['moon_sign'] as String?,
      favoriteCoffeeType: json['favorite_coffee_type'] as String?,
      readingPreference: json['reading_preference'] as String? ?? 'detailed',
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stats: json['stats'] == null
          ? null
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'photo_url': instance.photoUrl,
      'birth_date': instance.birthDate?.toIso8601String(),
      'birth_city': instance.birthCity,
      'gender': instance.gender,
      'zodiac_sign': instance.zodiacSign,
      'rising_sign': instance.risingSign,
      'moon_sign': instance.moonSign,
      'favorite_coffee_type': instance.favoriteCoffeeType,
      'reading_preference': instance.readingPreference,
      'is_premium': instance.isPremium,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'stats': instance.stats,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
