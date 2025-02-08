import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

part 'palm_reading.freezed.dart';
part 'palm_reading.g.dart';

class Vector2Converter implements JsonConverter<Vector2, List<double>> {
  const Vector2Converter();

  @override
  Vector2 fromJson(List<double> json) {
    return Vector2(json[0], json[1]);
  }

  @override
  List<double> toJson(Vector2 object) {
    return [object.x, object.y];
  }
}

@freezed
class PalmReading with _$PalmReading {
  const factory PalmReading({
    required String id,
    required String userId,
    required DateTime createdAt,
    required String imageUrl,
    @Vector2Converter() required Map<String, List<Vector2>> lineCoordinates,
    required Map<String, String> interpretations,
    String? aiAnalysis,
    @Default(false) bool isProcessed,
  }) = _PalmReading;

  factory PalmReading.fromJson(Map<String, dynamic> json) =>
      _$PalmReadingFromJson(json);
}
