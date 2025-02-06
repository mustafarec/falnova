// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CityImpl _$$CityImplFromJson(Map<String, dynamic> json) => _$CityImpl(
      name: json['name'] as String,
      region: json['region'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );

Map<String, dynamic> _$$CityImplToJson(_$CityImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$citiesHash() => r'27e03b2002d78d9f19967d31fc96c5fc8adcf132';

/// See also [cities].
@ProviderFor(cities)
final citiesProvider = AutoDisposeProvider<List<City>>.internal(
  cities,
  name: r'citiesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$citiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CitiesRef = AutoDisposeProviderRef<List<City>>;
String _$filteredCitiesHash() => r'9eb5d5299f5019428c4b40f9856e68054211ef61';

/// See also [filteredCities].
@ProviderFor(filteredCities)
final filteredCitiesProvider = AutoDisposeProvider<List<City>>.internal(
  filteredCities,
  name: r'filteredCitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredCitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCitiesRef = AutoDisposeProviderRef<List<City>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
