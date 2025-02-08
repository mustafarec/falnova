// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zodiac_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zodiacServiceHash() => r'bd908ddb006b6da2912d7aad5e5f2c1a2cc3fe39';

/// See also [zodiacService].
@ProviderFor(zodiacService)
final zodiacServiceProvider = AutoDisposeProvider<ZodiacService>.internal(
  zodiacService,
  name: r'zodiacServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zodiacServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ZodiacServiceRef = AutoDisposeProviderRef<ZodiacService>;
String _$ascendantSignHash() => r'5f2ac821525e12307466666cd78a40d8e462fd57';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [ascendantSign].
@ProviderFor(ascendantSign)
const ascendantSignProvider = AscendantSignFamily();

/// See also [ascendantSign].
class AscendantSignFamily extends Family<AsyncValue<String>> {
  /// See also [ascendantSign].
  const AscendantSignFamily();

  /// See also [ascendantSign].
  AscendantSignProvider call({
    required DateTime birthDate,
    required double latitude,
    required double longitude,
  }) {
    return AscendantSignProvider(
      birthDate: birthDate,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  AscendantSignProvider getProviderOverride(
    covariant AscendantSignProvider provider,
  ) {
    return call(
      birthDate: provider.birthDate,
      latitude: provider.latitude,
      longitude: provider.longitude,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ascendantSignProvider';
}

/// See also [ascendantSign].
class AscendantSignProvider extends AutoDisposeFutureProvider<String> {
  /// See also [ascendantSign].
  AscendantSignProvider({
    required DateTime birthDate,
    required double latitude,
    required double longitude,
  }) : this._internal(
          (ref) => ascendantSign(
            ref as AscendantSignRef,
            birthDate: birthDate,
            latitude: latitude,
            longitude: longitude,
          ),
          from: ascendantSignProvider,
          name: r'ascendantSignProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ascendantSignHash,
          dependencies: AscendantSignFamily._dependencies,
          allTransitiveDependencies:
              AscendantSignFamily._allTransitiveDependencies,
          birthDate: birthDate,
          latitude: latitude,
          longitude: longitude,
        );

  AscendantSignProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.birthDate,
    required this.latitude,
    required this.longitude,
  }) : super.internal();

  final DateTime birthDate;
  final double latitude;
  final double longitude;

  @override
  Override overrideWith(
    FutureOr<String> Function(AscendantSignRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AscendantSignProvider._internal(
        (ref) => create(ref as AscendantSignRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        birthDate: birthDate,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _AscendantSignProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AscendantSignProvider &&
        other.birthDate == birthDate &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, birthDate.hashCode);
    hash = _SystemHash.combine(hash, latitude.hashCode);
    hash = _SystemHash.combine(hash, longitude.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AscendantSignRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `birthDate` of this provider.
  DateTime get birthDate;

  /// The parameter `latitude` of this provider.
  double get latitude;

  /// The parameter `longitude` of this provider.
  double get longitude;
}

class _AscendantSignProviderElement
    extends AutoDisposeFutureProviderElement<String> with AscendantSignRef {
  _AscendantSignProviderElement(super.provider);

  @override
  DateTime get birthDate => (origin as AscendantSignProvider).birthDate;
  @override
  double get latitude => (origin as AscendantSignProvider).latitude;
  @override
  double get longitude => (origin as AscendantSignProvider).longitude;
}

String _$moonSignHash() => r'912122333562b184b83436bf0e5df4f52c36d319';

/// See also [moonSign].
@ProviderFor(moonSign)
const moonSignProvider = MoonSignFamily();

/// See also [moonSign].
class MoonSignFamily extends Family<AsyncValue<String>> {
  /// See also [moonSign].
  const MoonSignFamily();

  /// See also [moonSign].
  MoonSignProvider call({
    required DateTime birthDate,
  }) {
    return MoonSignProvider(
      birthDate: birthDate,
    );
  }

  @override
  MoonSignProvider getProviderOverride(
    covariant MoonSignProvider provider,
  ) {
    return call(
      birthDate: provider.birthDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'moonSignProvider';
}

/// See also [moonSign].
class MoonSignProvider extends AutoDisposeFutureProvider<String> {
  /// See also [moonSign].
  MoonSignProvider({
    required DateTime birthDate,
  }) : this._internal(
          (ref) => moonSign(
            ref as MoonSignRef,
            birthDate: birthDate,
          ),
          from: moonSignProvider,
          name: r'moonSignProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moonSignHash,
          dependencies: MoonSignFamily._dependencies,
          allTransitiveDependencies: MoonSignFamily._allTransitiveDependencies,
          birthDate: birthDate,
        );

  MoonSignProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.birthDate,
  }) : super.internal();

  final DateTime birthDate;

  @override
  Override overrideWith(
    FutureOr<String> Function(MoonSignRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MoonSignProvider._internal(
        (ref) => create(ref as MoonSignRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        birthDate: birthDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _MoonSignProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MoonSignProvider && other.birthDate == birthDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, birthDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MoonSignRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `birthDate` of this provider.
  DateTime get birthDate;
}

class _MoonSignProviderElement extends AutoDisposeFutureProviderElement<String>
    with MoonSignRef {
  _MoonSignProviderElement(super.provider);

  @override
  DateTime get birthDate => (origin as MoonSignProvider).birthDate;
}

String _$zodiacCompatibilityHash() =>
    r'9c46da8f9dc234d00c3c6dee642f116e7b3a4234';

/// See also [zodiacCompatibility].
@ProviderFor(zodiacCompatibility)
const zodiacCompatibilityProvider = ZodiacCompatibilityFamily();

/// See also [zodiacCompatibility].
class ZodiacCompatibilityFamily extends Family<AsyncValue<double>> {
  /// See also [zodiacCompatibility].
  const ZodiacCompatibilityFamily();

  /// See also [zodiacCompatibility].
  ZodiacCompatibilityProvider call({
    required String sign1,
    required String sign2,
  }) {
    return ZodiacCompatibilityProvider(
      sign1: sign1,
      sign2: sign2,
    );
  }

  @override
  ZodiacCompatibilityProvider getProviderOverride(
    covariant ZodiacCompatibilityProvider provider,
  ) {
    return call(
      sign1: provider.sign1,
      sign2: provider.sign2,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'zodiacCompatibilityProvider';
}

/// See also [zodiacCompatibility].
class ZodiacCompatibilityProvider extends AutoDisposeFutureProvider<double> {
  /// See also [zodiacCompatibility].
  ZodiacCompatibilityProvider({
    required String sign1,
    required String sign2,
  }) : this._internal(
          (ref) => zodiacCompatibility(
            ref as ZodiacCompatibilityRef,
            sign1: sign1,
            sign2: sign2,
          ),
          from: zodiacCompatibilityProvider,
          name: r'zodiacCompatibilityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zodiacCompatibilityHash,
          dependencies: ZodiacCompatibilityFamily._dependencies,
          allTransitiveDependencies:
              ZodiacCompatibilityFamily._allTransitiveDependencies,
          sign1: sign1,
          sign2: sign2,
        );

  ZodiacCompatibilityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sign1,
    required this.sign2,
  }) : super.internal();

  final String sign1;
  final String sign2;

  @override
  Override overrideWith(
    FutureOr<double> Function(ZodiacCompatibilityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZodiacCompatibilityProvider._internal(
        (ref) => create(ref as ZodiacCompatibilityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sign1: sign1,
        sign2: sign2,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _ZodiacCompatibilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZodiacCompatibilityProvider &&
        other.sign1 == sign1 &&
        other.sign2 == sign2;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sign1.hashCode);
    hash = _SystemHash.combine(hash, sign2.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ZodiacCompatibilityRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `sign1` of this provider.
  String get sign1;

  /// The parameter `sign2` of this provider.
  String get sign2;
}

class _ZodiacCompatibilityProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with ZodiacCompatibilityRef {
  _ZodiacCompatibilityProviderElement(super.provider);

  @override
  String get sign1 => (origin as ZodiacCompatibilityProvider).sign1;
  @override
  String get sign2 => (origin as ZodiacCompatibilityProvider).sign2;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
