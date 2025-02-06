// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horoscope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Horoscope _$HoroscopeFromJson(Map<String, dynamic> json) {
  return _Horoscope.fromJson(json);
}

/// @nodoc
mixin _$Horoscope {
  String get sign => throw _privateConstructorUsedError;
  String get dailyHoroscope => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  Map<String, int> get scores => throw _privateConstructorUsedError;
  String? get luckNumber => throw _privateConstructorUsedError;
  String? get luckColor => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;

  /// Serializes this Horoscope to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Horoscope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HoroscopeCopyWith<Horoscope> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoroscopeCopyWith<$Res> {
  factory $HoroscopeCopyWith(Horoscope value, $Res Function(Horoscope) then) =
      _$HoroscopeCopyWithImpl<$Res, Horoscope>;
  @useResult
  $Res call(
      {String sign,
      String dailyHoroscope,
      DateTime date,
      Map<String, int> scores,
      String? luckNumber,
      String? luckColor,
      bool isPremium});
}

/// @nodoc
class _$HoroscopeCopyWithImpl<$Res, $Val extends Horoscope>
    implements $HoroscopeCopyWith<$Res> {
  _$HoroscopeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Horoscope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? dailyHoroscope = null,
    Object? date = null,
    Object? scores = null,
    Object? luckNumber = freezed,
    Object? luckColor = freezed,
    Object? isPremium = null,
  }) {
    return _then(_value.copyWith(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      dailyHoroscope: null == dailyHoroscope
          ? _value.dailyHoroscope
          : dailyHoroscope // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scores: null == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      luckNumber: freezed == luckNumber
          ? _value.luckNumber
          : luckNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      luckColor: freezed == luckColor
          ? _value.luckColor
          : luckColor // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HoroscopeImplCopyWith<$Res>
    implements $HoroscopeCopyWith<$Res> {
  factory _$$HoroscopeImplCopyWith(
          _$HoroscopeImpl value, $Res Function(_$HoroscopeImpl) then) =
      __$$HoroscopeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sign,
      String dailyHoroscope,
      DateTime date,
      Map<String, int> scores,
      String? luckNumber,
      String? luckColor,
      bool isPremium});
}

/// @nodoc
class __$$HoroscopeImplCopyWithImpl<$Res>
    extends _$HoroscopeCopyWithImpl<$Res, _$HoroscopeImpl>
    implements _$$HoroscopeImplCopyWith<$Res> {
  __$$HoroscopeImplCopyWithImpl(
      _$HoroscopeImpl _value, $Res Function(_$HoroscopeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Horoscope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? dailyHoroscope = null,
    Object? date = null,
    Object? scores = null,
    Object? luckNumber = freezed,
    Object? luckColor = freezed,
    Object? isPremium = null,
  }) {
    return _then(_$HoroscopeImpl(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      dailyHoroscope: null == dailyHoroscope
          ? _value.dailyHoroscope
          : dailyHoroscope // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scores: null == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      luckNumber: freezed == luckNumber
          ? _value.luckNumber
          : luckNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      luckColor: freezed == luckColor
          ? _value.luckColor
          : luckColor // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HoroscopeImpl implements _Horoscope {
  const _$HoroscopeImpl(
      {required this.sign,
      required this.dailyHoroscope,
      required this.date,
      required final Map<String, int> scores,
      this.luckNumber,
      this.luckColor,
      this.isPremium = false})
      : _scores = scores;

  factory _$HoroscopeImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoroscopeImplFromJson(json);

  @override
  final String sign;
  @override
  final String dailyHoroscope;
  @override
  final DateTime date;
  final Map<String, int> _scores;
  @override
  Map<String, int> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

  @override
  final String? luckNumber;
  @override
  final String? luckColor;
  @override
  @JsonKey()
  final bool isPremium;

  @override
  String toString() {
    return 'Horoscope(sign: $sign, dailyHoroscope: $dailyHoroscope, date: $date, scores: $scores, luckNumber: $luckNumber, luckColor: $luckColor, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoroscopeImpl &&
            (identical(other.sign, sign) || other.sign == sign) &&
            (identical(other.dailyHoroscope, dailyHoroscope) ||
                other.dailyHoroscope == dailyHoroscope) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.luckNumber, luckNumber) ||
                other.luckNumber == luckNumber) &&
            (identical(other.luckColor, luckColor) ||
                other.luckColor == luckColor) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sign,
      dailyHoroscope,
      date,
      const DeepCollectionEquality().hash(_scores),
      luckNumber,
      luckColor,
      isPremium);

  /// Create a copy of Horoscope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HoroscopeImplCopyWith<_$HoroscopeImpl> get copyWith =>
      __$$HoroscopeImplCopyWithImpl<_$HoroscopeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoroscopeImplToJson(
      this,
    );
  }
}

abstract class _Horoscope implements Horoscope {
  const factory _Horoscope(
      {required final String sign,
      required final String dailyHoroscope,
      required final DateTime date,
      required final Map<String, int> scores,
      final String? luckNumber,
      final String? luckColor,
      final bool isPremium}) = _$HoroscopeImpl;

  factory _Horoscope.fromJson(Map<String, dynamic> json) =
      _$HoroscopeImpl.fromJson;

  @override
  String get sign;
  @override
  String get dailyHoroscope;
  @override
  DateTime get date;
  @override
  Map<String, int> get scores;
  @override
  String? get luckNumber;
  @override
  String? get luckColor;
  @override
  bool get isPremium;

  /// Create a copy of Horoscope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoroscopeImplCopyWith<_$HoroscopeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
