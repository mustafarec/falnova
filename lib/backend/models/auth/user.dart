import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required DateTime birthDate,
    required String birthPlace,
    required double birthLat,
    required double birthLng,
    BirthChart? birthChart,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
