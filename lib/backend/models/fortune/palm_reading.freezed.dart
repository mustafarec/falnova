// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'palm_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PalmReading _$PalmReadingFromJson(Map<String, dynamic> json) {
  return _PalmReading.fromJson(json);
}

/// @nodoc
mixin _$PalmReading {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  @Vector2Converter()
  Map<String, List<Vector2>> get lineCoordinates =>
      throw _privateConstructorUsedError;
  Map<String, String> get interpretations => throw _privateConstructorUsedError;
  String? get aiAnalysis => throw _privateConstructorUsedError;
  bool get isProcessed => throw _privateConstructorUsedError;

  /// Serializes this PalmReading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PalmReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PalmReadingCopyWith<PalmReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PalmReadingCopyWith<$Res> {
  factory $PalmReadingCopyWith(
          PalmReading value, $Res Function(PalmReading) then) =
      _$PalmReadingCopyWithImpl<$Res, PalmReading>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String imageUrl,
      @Vector2Converter() Map<String, List<Vector2>> lineCoordinates,
      Map<String, String> interpretations,
      String? aiAnalysis,
      bool isProcessed});
}

/// @nodoc
class _$PalmReadingCopyWithImpl<$Res, $Val extends PalmReading>
    implements $PalmReadingCopyWith<$Res> {
  _$PalmReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PalmReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? imageUrl = null,
    Object? lineCoordinates = null,
    Object? interpretations = null,
    Object? aiAnalysis = freezed,
    Object? isProcessed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lineCoordinates: null == lineCoordinates
          ? _value.lineCoordinates
          : lineCoordinates // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Vector2>>,
      interpretations: null == interpretations
          ? _value.interpretations
          : interpretations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessed: null == isProcessed
          ? _value.isProcessed
          : isProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PalmReadingImplCopyWith<$Res>
    implements $PalmReadingCopyWith<$Res> {
  factory _$$PalmReadingImplCopyWith(
          _$PalmReadingImpl value, $Res Function(_$PalmReadingImpl) then) =
      __$$PalmReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      String imageUrl,
      @Vector2Converter() Map<String, List<Vector2>> lineCoordinates,
      Map<String, String> interpretations,
      String? aiAnalysis,
      bool isProcessed});
}

/// @nodoc
class __$$PalmReadingImplCopyWithImpl<$Res>
    extends _$PalmReadingCopyWithImpl<$Res, _$PalmReadingImpl>
    implements _$$PalmReadingImplCopyWith<$Res> {
  __$$PalmReadingImplCopyWithImpl(
      _$PalmReadingImpl _value, $Res Function(_$PalmReadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of PalmReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? imageUrl = null,
    Object? lineCoordinates = null,
    Object? interpretations = null,
    Object? aiAnalysis = freezed,
    Object? isProcessed = null,
  }) {
    return _then(_$PalmReadingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lineCoordinates: null == lineCoordinates
          ? _value._lineCoordinates
          : lineCoordinates // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Vector2>>,
      interpretations: null == interpretations
          ? _value._interpretations
          : interpretations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      aiAnalysis: freezed == aiAnalysis
          ? _value.aiAnalysis
          : aiAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessed: null == isProcessed
          ? _value.isProcessed
          : isProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PalmReadingImpl implements _PalmReading {
  const _$PalmReadingImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.imageUrl,
      @Vector2Converter()
      required final Map<String, List<Vector2>> lineCoordinates,
      required final Map<String, String> interpretations,
      this.aiAnalysis,
      this.isProcessed = false})
      : _lineCoordinates = lineCoordinates,
        _interpretations = interpretations;

  factory _$PalmReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$PalmReadingImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final String imageUrl;
  final Map<String, List<Vector2>> _lineCoordinates;
  @override
  @Vector2Converter()
  Map<String, List<Vector2>> get lineCoordinates {
    if (_lineCoordinates is EqualUnmodifiableMapView) return _lineCoordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lineCoordinates);
  }

  final Map<String, String> _interpretations;
  @override
  Map<String, String> get interpretations {
    if (_interpretations is EqualUnmodifiableMapView) return _interpretations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_interpretations);
  }

  @override
  final String? aiAnalysis;
  @override
  @JsonKey()
  final bool isProcessed;

  @override
  String toString() {
    return 'PalmReading(id: $id, userId: $userId, createdAt: $createdAt, imageUrl: $imageUrl, lineCoordinates: $lineCoordinates, interpretations: $interpretations, aiAnalysis: $aiAnalysis, isProcessed: $isProcessed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PalmReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._lineCoordinates, _lineCoordinates) &&
            const DeepCollectionEquality()
                .equals(other._interpretations, _interpretations) &&
            (identical(other.aiAnalysis, aiAnalysis) ||
                other.aiAnalysis == aiAnalysis) &&
            (identical(other.isProcessed, isProcessed) ||
                other.isProcessed == isProcessed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      imageUrl,
      const DeepCollectionEquality().hash(_lineCoordinates),
      const DeepCollectionEquality().hash(_interpretations),
      aiAnalysis,
      isProcessed);

  /// Create a copy of PalmReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PalmReadingImplCopyWith<_$PalmReadingImpl> get copyWith =>
      __$$PalmReadingImplCopyWithImpl<_$PalmReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PalmReadingImplToJson(
      this,
    );
  }
}

abstract class _PalmReading implements PalmReading {
  const factory _PalmReading(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final String imageUrl,
      @Vector2Converter()
      required final Map<String, List<Vector2>> lineCoordinates,
      required final Map<String, String> interpretations,
      final String? aiAnalysis,
      final bool isProcessed}) = _$PalmReadingImpl;

  factory _PalmReading.fromJson(Map<String, dynamic> json) =
      _$PalmReadingImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  String get imageUrl;
  @override
  @Vector2Converter()
  Map<String, List<Vector2>> get lineCoordinates;
  @override
  Map<String, String> get interpretations;
  @override
  String? get aiAnalysis;
  @override
  bool get isProcessed;

  /// Create a copy of PalmReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PalmReadingImplCopyWith<_$PalmReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
