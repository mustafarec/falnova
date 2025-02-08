import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'package:falnova/backend/services/astrology/birth_chart_service.dart';
import 'package:falnova/ui/widgets/astrology/house_interpretation_card.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

class HouseSystemsScreen extends HookConsumerWidget {
  const HouseSystemsScreen({super.key});

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
        title: 'Ev Sistemleri',
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
                                'Yaşam Alanlarınız',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Doğum haritanızdaki 12 evin anlamları ve etkileri',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ev Yorumları
                        ...birthChart.value!.houses.entries.map(
                          (entry) => HouseInterpretationCard(
                            houseNumber: int.parse(entry.key.split(' ')[1]),
                            house: entry.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
