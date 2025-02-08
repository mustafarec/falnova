import 'package:flutter/material.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'package:falnova/backend/services/astrology/house_interpretation_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HouseInterpretationCard extends ConsumerWidget {
  final int houseNumber;
  final HouseSystem house;

  const HouseInterpretationCard({
    super.key,
    required this.houseNumber,
    required this.house,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interpretation = ref
        .watch(houseInterpretationServiceProvider.notifier)
        .getHouseInterpretation(
          houseNumber,
          house.sign,
          house.planets,
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$houseNumber',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ev $houseNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${house.sign} Burcu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gezegenler
            if (house.planets.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: house.planets.map((planet) {
                  return Chip(
                    label: Text(planet),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Yorum
            Text(
              interpretation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
