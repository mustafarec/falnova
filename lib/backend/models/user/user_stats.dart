import 'package:json_annotation/json_annotation.dart';

part 'user_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserStats {
  final String id;
  final int totalReadings;
  final int premiumReadings;
  final int standardReadings;
  final DateTime? lastReadingDate;
  final String? favoriteFortuneTeller;
  final double? averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    required this.id,
    this.totalReadings = 0,
    this.premiumReadings = 0,
    this.standardReadings = 0,
    this.lastReadingDate,
    this.favoriteFortuneTeller,
    this.averageRating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    String? id,
    int? totalReadings,
    int? premiumReadings,
    int? standardReadings,
    DateTime? lastReadingDate,
    String? favoriteFortuneTeller,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      id: id ?? this.id,
      totalReadings: totalReadings ?? this.totalReadings,
      premiumReadings: premiumReadings ?? this.premiumReadings,
      standardReadings: standardReadings ?? this.standardReadings,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      favoriteFortuneTeller:
          favoriteFortuneTeller ?? this.favoriteFortuneTeller,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
