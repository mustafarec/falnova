import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/core/data/cities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'city_search_screen.g.dart';

@riverpod
class CityList extends _$CityList {
  static const int pageSize = 20;

  @override
  List<City> build() {
    return turkishCities.take(pageSize).toList();
  }

  void loadMore() {
    if (state.length >= turkishCities.length) return;

    final nextIndex = state.length;
    final nextItems = turkishCities.skip(nextIndex).take(pageSize).toList();

    state = [...state, ...nextItems];
  }
}

@riverpod
List<City> filteredCities(Ref ref) {
  final cities = ref.watch(cityListProvider);
  final searchQuery = ref.watch(citySearchProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return cities;
  }

  return cities.where((city) {
    return city.name.toLowerCase().contains(searchQuery) ||
        city.region.toLowerCase().contains(searchQuery);
  }).toList();
}

@riverpod
class CitySearch extends _$CitySearch {
  @override
  String build() => '';

  void search(String query) => state = query;
}

class CitySearchScreen extends ConsumerWidget {
  const CitySearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Seç'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Şehir ara...',
              onChanged: (query) {
                ref.read(citySearchProvider.notifier).search(query);
              },
              leading: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final cities = ref.watch(filteredCitiesProvider);

          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(city.name),
                subtitle: Text(city.region),
                onTap: () {
                  Navigator.pop(context, city);
                },
              );
            },
          );
        },
      ),
    );
  }
}
