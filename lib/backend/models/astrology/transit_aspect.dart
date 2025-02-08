import 'package:freezed_annotation/freezed_annotation.dart';

part 'transit_aspect.freezed.dart';
part 'transit_aspect.g.dart';

@freezed
class TransitAspect with _$TransitAspect {
  const factory TransitAspect({
    required String transitPlanet,
    required String sign,
    required double degree,
    required bool isRetrograde,
    required String aspectType,
    required String interpretation,
    String? natalPlanet,
    double? orb,
    @Default([]) List<NatalAspect> aspectsToNatal,
  }) = _TransitAspect;

  factory TransitAspect.fromJson(Map<String, dynamic> json) =>
      _$TransitAspectFromJson(json);
}

@freezed
class NatalAspect with _$NatalAspect {
  const factory NatalAspect({
    required String natalPlanet,
    required String aspectType,
    required double orb,
    required bool isApplying,
    required String interpretation,
  }) = _NatalAspect;

  factory NatalAspect.fromJson(Map<String, dynamic> json) =>
      _$NatalAspectFromJson(json);
}
