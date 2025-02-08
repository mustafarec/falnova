import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:falnova/backend/services/astrology/transit_service.dart';
import 'package:falnova/backend/models/astrology/transit_aspect.dart';
import 'package:falnova/backend/services/astrology/birth_chart_service.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class TransitScreen extends HookConsumerWidget {
  const TransitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final supabase = ref.watch(supabaseServiceProvider);
    final birthChartService = ref.read(birthChartServiceProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Transit Gezegenler',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Tarih Seçici
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple,
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  ref.read(selectedDateProvider.notifier).state = date;
                }
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transit Listesi
          Expanded(
            child: FutureBuilder<BirthChart>(
              future: birthChartService.calculateBirthChart(
                userId: supabase.currentUser?.id ?? '',
                birthDate: selectedDate,
                birthPlace: 'Unknown',
                latitude: 0,
                longitude: 0,
              ),
              builder: (context, birthChartSnapshot) {
                if (birthChartSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (birthChartSnapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${birthChartSnapshot.error}'),
                  );
                }

                final birthChart = birthChartSnapshot.data;

                return FutureBuilder<List<TransitAspect>>(
                  future: ref.read(transitServiceProvider).getTransits(
                        date: selectedDate,
                        birthChart: birthChart,
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Hata: ${snapshot.error}'),
                      );
                    }

                    final transitList = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transitList.length,
                      itemBuilder: (context, index) {
                        final transit = transitList[index];
                        return _TransitCard(
                          planet: transit.transitPlanet,
                          sign: transit.sign,
                          degree: transit.degree.toInt(),
                          isRetrograde: transit.isRetrograde,
                          aspectsToNatal: transit.aspectsToNatal,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitCard extends StatelessWidget {
  final String planet;
  final String sign;
  final int degree;
  final bool isRetrograde;
  final List<NatalAspect> aspectsToNatal;

  const _TransitCard({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.isRetrograde,
    required this.aspectsToNatal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  planet,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRetrograde) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.replay,
                    size: 16,
                    color: Colors.red,
                  ),
                  const Text(
                    ' Retro',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$sign burcunda $degree°',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            if (aspectsToNatal.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Natal Açılar:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...aspectsToNatal.map((aspect) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${aspect.natalPlanet} ile ${aspect.aspectType} (${aspect.orb.toStringAsFixed(1)}°)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              ...aspectsToNatal.map((aspect) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      aspect.interpretation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
