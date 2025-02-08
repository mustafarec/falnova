import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:falnova/backend/services/astrology/ascendant_service.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

class AscendantScreen extends HookConsumerWidget {
  const AscendantScreen({super.key});

  Future<void> _loadAscendantData({
    required ValueNotifier<Map<String, dynamic>?> ascendantData,
    required ValueNotifier<Map<String, dynamic>?> moonData,
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

      final service = ref.read(ascendantServiceProvider.notifier);

      // Yükselen burç hesaplama
      final ascData = await service.calculateAscendant(
        birthDate: birthDate,
        latitude: latitude,
        longitude: longitude,
      );
      ascendantData.value = ascData;

      // Ay burcu hesaplama
      final moonAscData = await service.calculateMoonAscendant(
        birthDate: birthDate,
        latitude: latitude,
        longitude: longitude,
      );
      moonData.value = moonAscData;

      error.value = null;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildAscendantCard(
    BuildContext context,
    Map<String, dynamic> data,
    AscendantService service,
  ) {
    final sign = data['sign'] as String;
    final degree = data['degree'] as double;
    final decan = data['decan'] as int;
    final ruler = data['ruler'] as String;
    final rulerPosition = data['ruler_position'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yükselen $sign',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${degree.toStringAsFixed(2)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Dekan $decan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              service.getDecanInterpretation(sign, decan),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Yönetici Gezegen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              service.getRulerInterpretation(ruler, rulerPosition),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonCard(
    BuildContext context,
    Map<String, dynamic> data,
    AscendantService service,
  ) {
    final sign = data['sign'] as String;
    final degree = data['degree'] as double;
    final decan = data['decan'] as int;
    final ruler = data['ruler'] as String;
    final rulerPosition = data['ruler_position'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ay Burcu $sign',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${degree.toStringAsFixed(2)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Dekan $decan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              service.getDecanInterpretation(sign, decan),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Yönetici Gezegen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              service.getRulerInterpretation(ruler, rulerPosition),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ascendantData = useState<Map<String, dynamic>?>(null);
    final moonData = useState<Map<String, dynamic>?>(null);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    useEffect(() {
      _loadAscendantData(
        ascendantData: ascendantData,
        moonData: moonData,
        isLoading: isLoading,
        error: error,
        ref: ref,
      );
      return null;
    }, []);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Yükselen ve Ay Burcu',
        showBackButton: true,
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : error.value != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error.value!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadAscendantData(
                          ascendantData: ascendantData,
                          moonData: moonData,
                          isLoading: isLoading,
                          error: error,
                          ref: ref,
                        ),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : ascendantData.value == null || moonData.value == null
                  ? const Center(child: Text('Veri yüklenemedi'))
                  : SingleChildScrollView(
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
                                  'Yükselen ve Ay Burcu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Doğum haritanızın temel yapı taşları',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Yükselen Burç
                          _buildAscendantCard(
                            context,
                            ascendantData.value!,
                            ref.read(ascendantServiceProvider.notifier),
                          ),
                          const SizedBox(height: 24),

                          // Ay Burcu
                          _buildMoonCard(
                            context,
                            moonData.value!,
                            ref.read(ascendantServiceProvider.notifier),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
