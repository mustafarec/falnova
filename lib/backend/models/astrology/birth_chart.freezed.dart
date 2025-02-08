// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'birth_chart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BirthChart _$BirthChartFromJson(Map<String, dynamic> json) {
  return _BirthChart.fromJson(json);
}

/// @nodoc
mixin _$BirthChart {
  String get userId => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  String get birthPlace => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  Map<String, PlanetPosition> get planets => throw _privateConstructorUsedError;
  Map<String, HouseSystem> get houses => throw _privateConstructorUsedError;
  Map<String, List<Aspect>> get aspects => throw _privateConstructorUsedError;

  /// Serializes this BirthChart to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BirthChart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BirthChartCopyWith<BirthChart> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BirthChartCopyWith<$Res> {
  factory $BirthChartCopyWith(
          BirthChart value, $Res Function(BirthChart) then) =
      _$BirthChartCopyWithImpl<$Res, BirthChart>;
  @useResult
  $Res call(
      {String userId,
      DateTime birthDate,
      String birthPlace,
      double latitude,
      double longitude,
      Map<String, PlanetPosition> planets,
      Map<String, HouseSystem> houses,
      Map<String, List<Aspect>> aspects});
}

/// @nodoc
class _$BirthChartCopyWithImpl<$Res, $Val extends BirthChart>
    implements $BirthChartCopyWith<$Res> {
  _$BirthChartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BirthChart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? birthDate = null,
    Object? birthPlace = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? planets = null,
    Object? houses = null,
    Object? aspects = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthPlace: null == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      planets: null == planets
          ? _value.planets
          : planets // ignore: cast_nullable_to_non_nullable
              as Map<String, PlanetPosition>,
      houses: null == houses
          ? _value.houses
          : houses // ignore: cast_nullable_to_non_nullable
              as Map<String, HouseSystem>,
      aspects: null == aspects
          ? _value.aspects
          : aspects // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Aspect>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BirthChartImplCopyWith<$Res>
    implements $BirthChartCopyWith<$Res> {
  factory _$$BirthChartImplCopyWith(
          _$BirthChartImpl value, $Res Function(_$BirthChartImpl) then) =
      __$$BirthChartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime birthDate,
      String birthPlace,
      double latitude,
      double longitude,
      Map<String, PlanetPosition> planets,
      Map<String, HouseSystem> houses,
      Map<String, List<Aspect>> aspects});
}

/// @nodoc
class __$$BirthChartImplCopyWithImpl<$Res>
    extends _$BirthChartCopyWithImpl<$Res, _$BirthChartImpl>
    implements _$$BirthChartImplCopyWith<$Res> {
  __$$BirthChartImplCopyWithImpl(
      _$BirthChartImpl _value, $Res Function(_$BirthChartImpl) _then)
      : super(_value, _then);

  /// Create a copy of BirthChart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? birthDate = null,
    Object? birthPlace = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? planets = null,
    Object? houses = null,
    Object? aspects = null,
  }) {
    return _then(_$BirthChartImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthPlace: null == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      planets: null == planets
          ? _value._planets
          : planets // ignore: cast_nullable_to_non_nullable
              as Map<String, PlanetPosition>,
      houses: null == houses
          ? _value._houses
          : houses // ignore: cast_nullable_to_non_nullable
              as Map<String, HouseSystem>,
      aspects: null == aspects
          ? _value._aspects
          : aspects // ignore: cast_nullable_to_non_nullable
              as Map<String, List<Aspect>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BirthChartImpl implements _BirthChart {
  const _$BirthChartImpl(
      {required this.userId,
      required this.birthDate,
      required this.birthPlace,
      required this.latitude,
      required this.longitude,
      required final Map<String, PlanetPosition> planets,
      required final Map<String, HouseSystem> houses,
      required final Map<String, List<Aspect>> aspects})
      : _planets = planets,
        _houses = houses,
        _aspects = aspects;

  factory _$BirthChartImpl.fromJson(Map<String, dynamic> json) =>
      _$$BirthChartImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime birthDate;
  @override
  final String birthPlace;
  @override
  final double latitude;
  @override
  final double longitude;
  final Map<String, PlanetPosition> _planets;
  @override
  Map<String, PlanetPosition> get planets {
    if (_planets is EqualUnmodifiableMapView) return _planets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_planets);
  }

  final Map<String, HouseSystem> _houses;
  @override
  Map<String, HouseSystem> get houses {
    if (_houses is EqualUnmodifiableMapView) return _houses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_houses);
  }

  final Map<String, List<Aspect>> _aspects;
  @override
  Map<String, List<Aspect>> get aspects {
    if (_aspects is EqualUnmodifiableMapView) return _aspects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_aspects);
  }

  @override
  String toString() {
    return 'BirthChart(userId: $userId, birthDate: $birthDate, birthPlace: $birthPlace, latitude: $latitude, longitude: $longitude, planets: $planets, houses: $houses, aspects: $aspects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BirthChartImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._planets, _planets) &&
            const DeepCollectionEquality().equals(other._houses, _houses) &&
            const DeepCollectionEquality().equals(other._aspects, _aspects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      birthDate,
      birthPlace,
      latitude,
      longitude,
      const DeepCollectionEquality().hash(_planets),
      const DeepCollectionEquality().hash(_houses),
      const DeepCollectionEquality().hash(_aspects));

  /// Create a copy of BirthChart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BirthChartImplCopyWith<_$BirthChartImpl> get copyWith =>
      __$$BirthChartImplCopyWithImpl<_$BirthChartImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BirthChartImplToJson(
      this,
    );
  }
}

abstract class _BirthChart implements BirthChart {
  const factory _BirthChart(
      {required final String userId,
      required final DateTime birthDate,
      required final String birthPlace,
      required final double latitude,
      required final double longitude,
      required final Map<String, PlanetPosition> planets,
      required final Map<String, HouseSystem> houses,
      required final Map<String, List<Aspect>> aspects}) = _$BirthChartImpl;

  factory _BirthChart.fromJson(Map<String, dynamic> json) =
      _$BirthChartImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get birthDate;
  @override
  String get birthPlace;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  Map<String, PlanetPosition> get planets;
  @override
  Map<String, HouseSystem> get houses;
  @override
  Map<String, List<Aspect>> get aspects;

  /// Create a copy of BirthChart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BirthChartImplCopyWith<_$BirthChartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanetPosition _$PlanetPositionFromJson(Map<String, dynamic> json) {
  return _PlanetPosition.fromJson(json);
}

/// @nodoc
mixin _$PlanetPosition {
  String get sign => throw _privateConstructorUsedError;
  double get degree => throw _privateConstructorUsedError;
  bool get isRetrograde => throw _privateConstructorUsedError;
  int get house => throw _privateConstructorUsedError;

  /// Serializes this PlanetPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanetPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanetPositionCopyWith<PlanetPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanetPositionCopyWith<$Res> {
  factory $PlanetPositionCopyWith(
          PlanetPosition value, $Res Function(PlanetPosition) then) =
      _$PlanetPositionCopyWithImpl<$Res, PlanetPosition>;
  @useResult
  $Res call({String sign, double degree, bool isRetrograde, int house});
}

/// @nodoc
class _$PlanetPositionCopyWithImpl<$Res, $Val extends PlanetPosition>
    implements $PlanetPositionCopyWith<$Res> {
  _$PlanetPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanetPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? degree = null,
    Object? isRetrograde = null,
    Object? house = null,
  }) {
    return _then(_value.copyWith(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as double,
      isRetrograde: null == isRetrograde
          ? _value.isRetrograde
          : isRetrograde // ignore: cast_nullable_to_non_nullable
              as bool,
      house: null == house
          ? _value.house
          : house // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanetPositionImplCopyWith<$Res>
    implements $PlanetPositionCopyWith<$Res> {
  factory _$$PlanetPositionImplCopyWith(_$PlanetPositionImpl value,
          $Res Function(_$PlanetPositionImpl) then) =
      __$$PlanetPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sign, double degree, bool isRetrograde, int house});
}

/// @nodoc
class __$$PlanetPositionImplCopyWithImpl<$Res>
    extends _$PlanetPositionCopyWithImpl<$Res, _$PlanetPositionImpl>
    implements _$$PlanetPositionImplCopyWith<$Res> {
  __$$PlanetPositionImplCopyWithImpl(
      _$PlanetPositionImpl _value, $Res Function(_$PlanetPositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlanetPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? degree = null,
    Object? isRetrograde = null,
    Object? house = null,
  }) {
    return _then(_$PlanetPositionImpl(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as double,
      isRetrograde: null == isRetrograde
          ? _value.isRetrograde
          : isRetrograde // ignore: cast_nullable_to_non_nullable
              as bool,
      house: null == house
          ? _value.house
          : house // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanetPositionImpl implements _PlanetPosition {
  const _$PlanetPositionImpl(
      {required this.sign,
      required this.degree,
      required this.isRetrograde,
      required this.house});

  factory _$PlanetPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanetPositionImplFromJson(json);

  @override
  final String sign;
  @override
  final double degree;
  @override
  final bool isRetrograde;
  @override
  final int house;

  @override
  String toString() {
    return 'PlanetPosition(sign: $sign, degree: $degree, isRetrograde: $isRetrograde, house: $house)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanetPositionImpl &&
            (identical(other.sign, sign) || other.sign == sign) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.isRetrograde, isRetrograde) ||
                other.isRetrograde == isRetrograde) &&
            (identical(other.house, house) || other.house == house));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sign, degree, isRetrograde, house);

  /// Create a copy of PlanetPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanetPositionImplCopyWith<_$PlanetPositionImpl> get copyWith =>
      __$$PlanetPositionImplCopyWithImpl<_$PlanetPositionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanetPositionImplToJson(
      this,
    );
  }
}

abstract class _PlanetPosition implements PlanetPosition {
  const factory _PlanetPosition(
      {required final String sign,
      required final double degree,
      required final bool isRetrograde,
      required final int house}) = _$PlanetPositionImpl;

  factory _PlanetPosition.fromJson(Map<String, dynamic> json) =
      _$PlanetPositionImpl.fromJson;

  @override
  String get sign;
  @override
  double get degree;
  @override
  bool get isRetrograde;
  @override
  int get house;

  /// Create a copy of PlanetPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanetPositionImplCopyWith<_$PlanetPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HouseSystem _$HouseSystemFromJson(Map<String, dynamic> json) {
  return _HouseSystem.fromJson(json);
}

/// @nodoc
mixin _$HouseSystem {
  String get sign => throw _privateConstructorUsedError;
  double get degree => throw _privateConstructorUsedError;
  List<String> get planets => throw _privateConstructorUsedError;

  /// Serializes this HouseSystem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HouseSystem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseSystemCopyWith<HouseSystem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseSystemCopyWith<$Res> {
  factory $HouseSystemCopyWith(
          HouseSystem value, $Res Function(HouseSystem) then) =
      _$HouseSystemCopyWithImpl<$Res, HouseSystem>;
  @useResult
  $Res call({String sign, double degree, List<String> planets});
}

/// @nodoc
class _$HouseSystemCopyWithImpl<$Res, $Val extends HouseSystem>
    implements $HouseSystemCopyWith<$Res> {
  _$HouseSystemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseSystem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? degree = null,
    Object? planets = null,
  }) {
    return _then(_value.copyWith(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as double,
      planets: null == planets
          ? _value.planets
          : planets // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseSystemImplCopyWith<$Res>
    implements $HouseSystemCopyWith<$Res> {
  factory _$$HouseSystemImplCopyWith(
          _$HouseSystemImpl value, $Res Function(_$HouseSystemImpl) then) =
      __$$HouseSystemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sign, double degree, List<String> planets});
}

/// @nodoc
class __$$HouseSystemImplCopyWithImpl<$Res>
    extends _$HouseSystemCopyWithImpl<$Res, _$HouseSystemImpl>
    implements _$$HouseSystemImplCopyWith<$Res> {
  __$$HouseSystemImplCopyWithImpl(
      _$HouseSystemImpl _value, $Res Function(_$HouseSystemImpl) _then)
      : super(_value, _then);

  /// Create a copy of HouseSystem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sign = null,
    Object? degree = null,
    Object? planets = null,
  }) {
    return _then(_$HouseSystemImpl(
      sign: null == sign
          ? _value.sign
          : sign // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as double,
      planets: null == planets
          ? _value._planets
          : planets // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseSystemImpl implements _HouseSystem {
  const _$HouseSystemImpl(
      {required this.sign,
      required this.degree,
      required final List<String> planets})
      : _planets = planets;

  factory _$HouseSystemImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseSystemImplFromJson(json);

  @override
  final String sign;
  @override
  final double degree;
  final List<String> _planets;
  @override
  List<String> get planets {
    if (_planets is EqualUnmodifiableListView) return _planets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planets);
  }

  @override
  String toString() {
    return 'HouseSystem(sign: $sign, degree: $degree, planets: $planets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseSystemImpl &&
            (identical(other.sign, sign) || other.sign == sign) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            const DeepCollectionEquality().equals(other._planets, _planets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, sign, degree, const DeepCollectionEquality().hash(_planets));

  /// Create a copy of HouseSystem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseSystemImplCopyWith<_$HouseSystemImpl> get copyWith =>
      __$$HouseSystemImplCopyWithImpl<_$HouseSystemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseSystemImplToJson(
      this,
    );
  }
}

abstract class _HouseSystem implements HouseSystem {
  const factory _HouseSystem(
      {required final String sign,
      required final double degree,
      required final List<String> planets}) = _$HouseSystemImpl;

  factory _HouseSystem.fromJson(Map<String, dynamic> json) =
      _$HouseSystemImpl.fromJson;

  @override
  String get sign;
  @override
  double get degree;
  @override
  List<String> get planets;

  /// Create a copy of HouseSystem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseSystemImplCopyWith<_$HouseSystemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Aspect _$AspectFromJson(Map<String, dynamic> json) {
  return _Aspect.fromJson(json);
}

/// @nodoc
mixin _$Aspect {
  String get planet1 => throw _privateConstructorUsedError;
  String get planet2 => throw _privateConstructorUsedError;
  String get aspectType => throw _privateConstructorUsedError;
  double get orb => throw _privateConstructorUsedError;
  bool get isApplying => throw _privateConstructorUsedError;

  /// Serializes this Aspect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AspectCopyWith<Aspect> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AspectCopyWith<$Res> {
  factory $AspectCopyWith(Aspect value, $Res Function(Aspect) then) =
      _$AspectCopyWithImpl<$Res, Aspect>;
  @useResult
  $Res call(
      {String planet1,
      String planet2,
      String aspectType,
      double orb,
      bool isApplying});
}

/// @nodoc
class _$AspectCopyWithImpl<$Res, $Val extends Aspect>
    implements $AspectCopyWith<$Res> {
  _$AspectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planet1 = null,
    Object? planet2 = null,
    Object? aspectType = null,
    Object? orb = null,
    Object? isApplying = null,
  }) {
    return _then(_value.copyWith(
      planet1: null == planet1
          ? _value.planet1
          : planet1 // ignore: cast_nullable_to_non_nullable
              as String,
      planet2: null == planet2
          ? _value.planet2
          : planet2 // ignore: cast_nullable_to_non_nullable
              as String,
      aspectType: null == aspectType
          ? _value.aspectType
          : aspectType // ignore: cast_nullable_to_non_nullable
              as String,
      orb: null == orb
          ? _value.orb
          : orb // ignore: cast_nullable_to_non_nullable
              as double,
      isApplying: null == isApplying
          ? _value.isApplying
          : isApplying // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AspectImplCopyWith<$Res> implements $AspectCopyWith<$Res> {
  factory _$$AspectImplCopyWith(
          _$AspectImpl value, $Res Function(_$AspectImpl) then) =
      __$$AspectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String planet1,
      String planet2,
      String aspectType,
      double orb,
      bool isApplying});
}

/// @nodoc
class __$$AspectImplCopyWithImpl<$Res>
    extends _$AspectCopyWithImpl<$Res, _$AspectImpl>
    implements _$$AspectImplCopyWith<$Res> {
  __$$AspectImplCopyWithImpl(
      _$AspectImpl _value, $Res Function(_$AspectImpl) _then)
      : super(_value, _then);

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planet1 = null,
    Object? planet2 = null,
    Object? aspectType = null,
    Object? orb = null,
    Object? isApplying = null,
  }) {
    return _then(_$AspectImpl(
      planet1: null == planet1
          ? _value.planet1
          : planet1 // ignore: cast_nullable_to_non_nullable
              as String,
      planet2: null == planet2
          ? _value.planet2
          : planet2 // ignore: cast_nullable_to_non_nullable
              as String,
      aspectType: null == aspectType
          ? _value.aspectType
          : aspectType // ignore: cast_nullable_to_non_nullable
              as String,
      orb: null == orb
          ? _value.orb
          : orb // ignore: cast_nullable_to_non_nullable
              as double,
      isApplying: null == isApplying
          ? _value.isApplying
          : isApplying // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AspectImpl implements _Aspect {
  const _$AspectImpl(
      {required this.planet1,
      required this.planet2,
      required this.aspectType,
      required this.orb,
      required this.isApplying});

  factory _$AspectImpl.fromJson(Map<String, dynamic> json) =>
      _$$AspectImplFromJson(json);

  @override
  final String planet1;
  @override
  final String planet2;
  @override
  final String aspectType;
  @override
  final double orb;
  @override
  final bool isApplying;

  @override
  String toString() {
    return 'Aspect(planet1: $planet1, planet2: $planet2, aspectType: $aspectType, orb: $orb, isApplying: $isApplying)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AspectImpl &&
            (identical(other.planet1, planet1) || other.planet1 == planet1) &&
            (identical(other.planet2, planet2) || other.planet2 == planet2) &&
            (identical(other.aspectType, aspectType) ||
                other.aspectType == aspectType) &&
            (identical(other.orb, orb) || other.orb == orb) &&
            (identical(other.isApplying, isApplying) ||
                other.isApplying == isApplying));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, planet1, planet2, aspectType, orb, isApplying);

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AspectImplCopyWith<_$AspectImpl> get copyWith =>
      __$$AspectImplCopyWithImpl<_$AspectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AspectImplToJson(
      this,
    );
  }
}

abstract class _Aspect implements Aspect {
  const factory _Aspect(
      {required final String planet1,
      required final String planet2,
      required final String aspectType,
      required final double orb,
      required final bool isApplying}) = _$AspectImpl;

  factory _Aspect.fromJson(Map<String, dynamic> json) = _$AspectImpl.fromJson;

  @override
  String get planet1;
  @override
  String get planet2;
  @override
  String get aspectType;
  @override
  double get orb;
  @override
  bool get isApplying;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AspectImplCopyWith<_$AspectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
