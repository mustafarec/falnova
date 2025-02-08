import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';
import 'package:falnova/backend/services/astrology/birth_chart_service.dart';
import 'package:falnova/ui/widgets/astrology/birth_chart_wheel.dart';
import 'package:intl/intl.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/ui/widgets/astrology/aspect_table.dart';

class BirthChartScreen extends HookConsumerWidget {
  const BirthChartScreen({super.key});

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

      // Kullanıcı profilini al
      final profile =
          await supabase.from('profiles').select().eq('id', user.id).single();

      final birthDateStr = profile['birth_date']?.toString();
      final birthTimeStr = profile['birth_time']?.toString();
      final birthCity = profile['birth_city']?.toString();

      if (birthDateStr == null || birthTimeStr == null || birthCity == null) {
        throw Exception('Doğum bilgileri eksik');
      }

      // Tarih ve saat bilgisini birleştir
      final birthDate = DateTime.parse('$birthDateStr\T$birthTimeStr');

      // Şehir koordinatlarını bul
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

    // Hata durumunu kontrol et
    if (error.value != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doğum Haritası'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata: ${error.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadBirthChart(
                  birthChart: birthChart,
                  isLoading: isLoading,
                  error: error,
                  ref: ref,
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doğum Haritası'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                                'Yıldızların Rehberliğinde',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Doğum anınızdaki gezegen konumları ve etkileri',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Doğum Bilgileri Kartı
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cake,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Doğum Bilgileri',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (birthChart.value != null) ...[
                                  _buildInfoRow(
                                    'Doğum Tarihi',
                                    DateFormat('dd.MM.yyyy')
                                        .format(birthChart.value!.birthDate),
                                  ),
                                  _buildInfoRow(
                                    'Doğum Saati',
                                    DateFormat('HH:mm')
                                        .format(birthChart.value!.birthDate),
                                  ),
                                  _buildInfoRow(
                                    'Doğum Yeri',
                                    birthChart.value!.birthPlace,
                                  ),
                                  _buildInfoRow(
                                    'Enlem',
                                    '${birthChart.value!.latitude.toStringAsFixed(4)}°',
                                  ),
                                  _buildInfoRow(
                                    'Boylam',
                                    '${birthChart.value!.longitude.toStringAsFixed(4)}°',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Doğum Haritası Görselleştirmesi
                        if (birthChart.value != null)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Doğum Haritası',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  BirthChartWheel(
                                    birthChart: birthChart.value!,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Gezegen Konumları
                        if (birthChart.value != null)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Gezegen Konumları',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...birthChart.value!.planets.entries.map(
                                    (planet) => _buildPlanetRow(
                                      planet.key,
                                      planet.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Açılar
                        if (birthChart.value != null)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                        'Açılar',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Açı Tablosu
                                  AspectTable(birthChart: birthChart.value!),
                                  const SizedBox(height: 16),
                                  // Açı Listesi
                                  const Text(
                                    'Açı Detayları',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                      ],
                                    ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetRow(String name, PlanetPosition position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${position.sign} ${position.degree.toStringAsFixed(2)}°',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Ev ${position.house}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (position.isRetrograde)
                  Row(
                    children: [
                      Icon(
                        Icons.replay,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Retrograd',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRow(Aspect aspect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
    );
  }
}
