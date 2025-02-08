import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/models/zodiac/zodiac_sign.dart';
import 'package:falnova/backend/services/zodiac/zodiac_service.dart';
import 'package:falnova/backend/services/fortune/gpt_service.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final selectedSign1Provider = StateProvider<String?>((ref) => null);
final selectedSign2Provider = StateProvider<String?>((ref) => null);

final compatibilityInterpretationProvider =
    FutureProvider.family<String, (String, String)>((ref, signs) async {
  final gptService = ref.watch(gptServiceProvider);
  final prompt = '''
    ${signs.$1} kadını ve ${signs.$2} erkeği burçlarının uyumluluğunu analiz et.
    Yanıtını aşağıdaki formatta ver:

    **${signs.$1} kadını ve ${signs.$2} erkeği uyumu**,
    (Genel bir giriş cümlesi)

    ⭐ **${signs.$1} Kadını ve ${signs.$2} Erkeğinin Karakteristik Özellikleri**

    ⭐ **${signs.$1} Kadını (... - ...):**
    * **Analitik ve Detaycı:** (özellik açıklaması)
    * **Titiz ve Düzenli:** (özellik açıklaması)
    * **Yardımsever ve Şefkatli:** (özellik açıklaması)

    ⭐ **${signs.$2} Erkeği (... - ...):**
    * **Özellik 1:** (açıklama)
    * **Özellik 2:** (açıklama)
    * **Özellik 3:** (açıklama)

    ⭐ **İlişkideki Güçlü Yönler:**
    * (madde 1)
    * (madde 2)
    * (madde 3)

    ⭐ **Dikkat Edilmesi Gerekenler:**
    * (madde 1)
    * (madde 2)
    * (madde 3)

    ⭐ **Günlük Yaşam Uyumu:**
    (Detaylı açıklama)
    ''';
  return await gptService.generateContent(prompt);
});

class CompatibilityScreen extends HookConsumerWidget {
  const CompatibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSign1 = ref.watch(selectedSign1Provider);
    final selectedSign2 = ref.watch(selectedSign2Provider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Burç Uyumluluğu',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Burç seçim kartları
            Row(
              children: [
                Expanded(
                  child: _ZodiacSelectCard(
                    title: 'Kadın Burcu',
                    selectedSign: selectedSign1,
                    onSelect: (sign) =>
                        ref.read(selectedSign1Provider.notifier).state = sign,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ZodiacSelectCard(
                    title: 'Erkek Burcu',
                    selectedSign: selectedSign2,
                    onSelect: (sign) =>
                        ref.read(selectedSign2Provider.notifier).state = sign,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Uyumluluk sonucu
            if (selectedSign1 != null && selectedSign2 != null) ...[
              FutureBuilder<double>(
                future: ref.read(zodiacCompatibilityProvider(
                  sign1: selectedSign1,
                  sign2: selectedSign2,
                ).future),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text(
                        'Uyumluluk hesaplanırken bir hata oluştu');
                  }

                  final compatibility = snapshot.data ?? 0.0;
                  final percentage = (compatibility * 100).toInt();

                  return Column(
                    children: [
                      Text(
                        '$selectedSign1 Kadın - $selectedSign2 Erkek\nUyumluluğu',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              value: compatibility,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: _getCompatibilityColor(compatibility),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '%$percentage',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color:
                                          _getCompatibilityColor(compatibility),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _getCompatibilityText(compatibility),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Detaylı yorum
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detaylı Analiz',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ref
                          .watch(compatibilityInterpretationProvider(
                              (selectedSign1, selectedSign2)))
                          .when(
                            data: (interpretation) => MarkdownBody(
                              data: interpretation,
                              styleSheet: MarkdownStyleSheet(
                                h1: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                h2: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                strong: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                listBullet:
                                    Theme.of(context).textTheme.bodyLarge,
                                p: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stack) => Text(
                              'Yorum yüklenirken bir hata oluştu: $error',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCompatibilityColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.lightGreen;
    if (value >= 0.4) return Colors.orange;
    if (value >= 0.2) return Colors.deepOrange;
    return Colors.red;
  }

  String _getCompatibilityText(double value) {
    if (value >= 0.8) return 'Mükemmel Uyum';
    if (value >= 0.6) return 'İyi Uyum';
    if (value >= 0.4) return 'Orta Uyum';
    if (value >= 0.2) return 'Düşük Uyum';
    return 'Uyumsuz';
  }
}

class _ZodiacSelectCard extends StatelessWidget {
  final String title;
  final String? selectedSign;
  final ValueChanged<String> onSelect;

  const _ZodiacSelectCard({
    required this.title,
    required this.selectedSign,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSign,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: ZodiacSign.allSigns
                  .map((sign) => DropdownMenuItem(
                        value: sign.name,
                        child: Text(sign.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onSelect(value);
              },
              hint: const Text('Burç Seç'),
            ),
          ],
        ),
      ),
    );
  }
}
