import 'package:freezed_annotation/freezed_annotation.dart';

part 'horoscope.freezed.dart';
part 'horoscope.g.dart';

@freezed
class Horoscope with _$Horoscope {
  const factory Horoscope({
    required String sign,
    required String dailyHoroscope,
    required DateTime date,
    required Map<String, int> scores,
    String? luckNumber,
    String? luckColor,
    @Default(false) bool isPremium,
  }) = _Horoscope;

  factory Horoscope.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeFromJson(json);
}
