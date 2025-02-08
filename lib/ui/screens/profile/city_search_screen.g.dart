// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCitiesHash() => r'a5a5dcf421c8e0ea93c7f5eec698675de20ef9f5';

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
String _$cityListHash() => r'4abafc97b7135ef08ee8604ff8439f9e4fa9dba3';

/// See also [CityList].
@ProviderFor(CityList)
final cityListProvider =
    AutoDisposeNotifierProvider<CityList, List<City>>.internal(
  CityList.new,
  name: r'cityListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cityListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CityList = AutoDisposeNotifier<List<City>>;
String _$citySearchHash() => r'91f271ca636c4f4136697332d3972ab4238c8e18';

/// See also [CitySearch].
@ProviderFor(CitySearch)
final citySearchProvider =
    AutoDisposeNotifierProvider<CitySearch, String>.internal(
  CitySearch.new,
  name: r'citySearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$citySearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CitySearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
