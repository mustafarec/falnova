import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'package:falnova/backend/services/astrology/birth_chart_service.dart';
import 'package:falnova/ui/widgets/astrology/aspect_table.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:falnova/backend/services/astrology/aspect_interpretation_service.dart';
import 'package:falnova/backend/services/astrology/aspect_pattern_service.dart';

class AspectCalculationsScreen extends HookConsumerWidget {
  const AspectCalculationsScreen({super.key});

  Future<void> _loadBirthChart({
    required ValueNotifier<BirthChart?> birthChart,
    required ValueNotifier<bool> isLoading,
    required ValueNotifier<String?> error,
    required WidgetRef ref,
  }) async {
    isLoading.value = true;
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final user = supabase.currentUser;

      if (user == null) {
        throw Exception('Oturum açık değil');
      }

      final profile =
          await supabase.from('profiles').select().eq('id', user.id).single();

      final birthDateStr = profile['birth_date']?.toString();
      final birthTimeStr = profile['birth_time']?.toString();
      final birthCity = profile['birth_city']?.toString();

      if (birthDateStr == null || birthTimeStr == null || birthCity == null) {
        throw Exception('Doğum bilgileri eksik');
      }

      final birthDate = DateTime.parse('$birthDateStr\T$birthTimeStr');

      final cities = ref.read(citiesProvider);
      final city = cities.firstWhere((c) => c.name == birthCity);
      final latitude = double.parse(city.latitude ?? "0");
      final longitude = double.parse(city.longitude ?? "0");

      final service = ref.read(birthChartServiceProvider.notifier);
      final chart = await service.calculateBirthChart(
        userId: user.id,
        birthDate: birthDate,
        birthPlace: birthCity,
        latitude: latitude,
        longitude: longitude,
      );
      birthChart.value = chart;
      error.value = null;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildAspectRow(Aspect aspect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${aspect.planet1} - ${aspect.planet2}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aspect.aspectType} (${aspect.orb.toStringAsFixed(2)}°)',
                      style: TextStyle(
                        fontSize: 12,
                        color: aspect.isApplying ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                aspect.isApplying ? Icons.arrow_downward : Icons.arrow_upward,
                size: 16,
                color: aspect.isApplying ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final interpretation = ref
                  .watch(aspectInterpretationServiceProvider.notifier)
                  .getAspectInterpretation(
                    aspect.planet1,
                    aspect.planet2,
                    aspect.aspectType,
                  );
              return Text(
                interpretation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthChart = useState<BirthChart?>(null);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    useEffect(() {
      _loadBirthChart(
        birthChart: birthChart,
        isLoading: isLoading,
        error: error,
        ref: ref,
      );
      return null;
    }, []);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Açı Hesaplamaları',
        showBackButton: true,
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : birthChart.value == null
              ? const Center(child: Text('Doğum haritası yüklenemedi'))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık ve Açıklama
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple.withOpacity(0.8),
                                Colors.purple.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gezegen Açıları',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Doğum haritanızdaki gezegenlerin birbirleriyle yaptıkları açılar ve etkileri',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Açı Tablosu
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.architecture,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Açı Tablosu',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AspectTable(birthChart: birthChart.value!),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Açı Listesi
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Açı Detayları',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...birthChart.value!.aspects.entries.map(
                                  (entry) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...entry.value.map(
                                        (aspect) => _buildAspectRow(aspect),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Açı Kalıpları
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pattern,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Açı Kalıpları',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final patterns = ref
                                        .watch(aspectPatternServiceProvider
                                            .notifier)
                                        .findAspectPatterns(birthChart.value!);

                                    if (patterns.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Doğum haritanızda belirgin bir açı kalıbı bulunmuyor.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: patterns.map((pattern) {
                                        final interpretation = ref
                                            .watch(aspectPatternServiceProvider
                                                .notifier)
                                            .getPatternInterpretation(pattern);

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pattern.type,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                pattern.description,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Gezegenler: ${pattern.planets.join(", ")}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                interpretation,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
