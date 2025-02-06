import 'package:json_annotation/json_annotation.dart';
import 'package:falnova/backend/models/user/user_stats.dart';

part 'user_profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? birthCity;
  final String? gender;
  final String? zodiacSign;
  final String? risingSign;
  final String? moonSign;
  final String? favoriteCoffeeType;
  final String readingPreference;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats? stats;
  final String? latitude;
  final String? longitude;

  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.photoUrl,
    this.birthDate,
    this.birthCity,
    this.gender,
    this.zodiacSign,
    this.risingSign,
    this.moonSign,
    this.favoriteCoffeeType,
    this.readingPreference = 'detailed',
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.latitude,
    this.longitude,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    DateTime? birthDate,
    String? birthCity,
    String? gender,
    String? zodiacSign,
    String? risingSign,
    String? moonSign,
    String? favoriteCoffeeType,
    String? readingPreference,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
    String? latitude,
    String? longitude,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      birthCity: birthCity ?? this.birthCity,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      risingSign: risingSign ?? this.risingSign,
      moonSign: moonSign ?? this.moonSign,
      favoriteCoffeeType: favoriteCoffeeType ?? this.favoriteCoffeeType,
      readingPreference: readingPreference ?? this.readingPreference,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
