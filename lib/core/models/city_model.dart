import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/core/data/cities.dart';
import 'package:falnova/ui/screens/profile/city_search_screen.dart';

part 'city_model.freezed.dart';
part 'city_model.g.dart';

@freezed
class City with _$City {
  const factory City({
    required String name,
    required String region,
    String? latitude,
    String? longitude,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

// Şehir listesi provider'ı
@riverpod
List<City> cities(Ref ref) {
  return turkishCities; // Tüm şehirleri döndür
}

// Filtrelenmiş şehirler provider'ı
@riverpod
List<City> filteredCities(Ref ref) {
  final cities = ref.watch(citiesProvider);
  final searchQuery = ref.watch(citySearchProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return cities;
  }

  return cities.where((city) {
    return city.name.toLowerCase().contains(searchQuery) ||
        city.region.toLowerCase().contains(searchQuery);
  }).toList();
}
