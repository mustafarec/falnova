// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  String get birthPlace => throw _privateConstructorUsedError;
  double get birthLat => throw _privateConstructorUsedError;
  double get birthLng => throw _privateConstructorUsedError;
  BirthChart? get birthChart => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      DateTime birthDate,
      String birthPlace,
      double birthLat,
      double birthLng,
      BirthChart? birthChart});

  $BirthChartCopyWith<$Res>? get birthChart;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? birthDate = null,
    Object? birthPlace = null,
    Object? birthLat = null,
    Object? birthLng = null,
    Object? birthChart = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthPlace: null == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String,
      birthLat: null == birthLat
          ? _value.birthLat
          : birthLat // ignore: cast_nullable_to_non_nullable
              as double,
      birthLng: null == birthLng
          ? _value.birthLng
          : birthLng // ignore: cast_nullable_to_non_nullable
              as double,
      birthChart: freezed == birthChart
          ? _value.birthChart
          : birthChart // ignore: cast_nullable_to_non_nullable
              as BirthChart?,
    ) as $Val);
  }

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BirthChartCopyWith<$Res>? get birthChart {
    if (_value.birthChart == null) {
      return null;
    }

    return $BirthChartCopyWith<$Res>(_value.birthChart!, (value) {
      return _then(_value.copyWith(birthChart: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      DateTime birthDate,
      String birthPlace,
      double birthLat,
      double birthLng,
      BirthChart? birthChart});

  @override
  $BirthChartCopyWith<$Res>? get birthChart;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? birthDate = null,
    Object? birthPlace = null,
    Object? birthLat = null,
    Object? birthLng = null,
    Object? birthChart = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthPlace: null == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String,
      birthLat: null == birthLat
          ? _value.birthLat
          : birthLat // ignore: cast_nullable_to_non_nullable
              as double,
      birthLng: null == birthLng
          ? _value.birthLng
          : birthLng // ignore: cast_nullable_to_non_nullable
              as double,
      birthChart: freezed == birthChart
          ? _value.birthChart
          : birthChart // ignore: cast_nullable_to_non_nullable
              as BirthChart?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.email,
      required this.name,
      required this.birthDate,
      required this.birthPlace,
      required this.birthLat,
      required this.birthLng,
      this.birthChart});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final DateTime birthDate;
  @override
  final String birthPlace;
  @override
  final double birthLat;
  @override
  final double birthLng;
  @override
  final BirthChart? birthChart;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, birthDate: $birthDate, birthPlace: $birthPlace, birthLat: $birthLat, birthLng: $birthLng, birthChart: $birthChart)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.birthLat, birthLat) ||
                other.birthLat == birthLat) &&
            (identical(other.birthLng, birthLng) ||
                other.birthLng == birthLng) &&
            (identical(other.birthChart, birthChart) ||
                other.birthChart == birthChart));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, name, birthDate,
      birthPlace, birthLat, birthLng, birthChart);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String email,
      required final String name,
      required final DateTime birthDate,
      required final String birthPlace,
      required final double birthLat,
      required final double birthLng,
      final BirthChart? birthChart}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  DateTime get birthDate;
  @override
  String get birthPlace;
  @override
  double get birthLat;
  @override
  double get birthLng;
  @override
  BirthChart? get birthChart;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
