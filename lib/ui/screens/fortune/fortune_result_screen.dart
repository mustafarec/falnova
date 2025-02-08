import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:falnova/backend/models/fortune/fortune_models.dart';
import 'package:falnova/backend/repositories/fortune/fortune_repository.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:intl/intl.dart';

class FortuneResultScreen extends ConsumerWidget {
  final String readingId;

  const FortuneResultScreen({super.key, required this.readingId});

  static const primaryColor = Colors.brown;
  static const secondaryColor = Colors.brown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: CustomAppBar(
        title: 'Kahve Falı Yorumu',
        showBackButton: true,
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              final futureReadings = ref
                  .watch(fortuneRepositoryProvider.notifier)
                  .getFortuneHistory();

              futureReadings.then((readings) {
                final reading = readings.firstWhere(
                  (r) => r.id == readingId,
                  orElse: () => throw Exception('Fal bulunamadı'),
                );

                final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR')
                    .format(reading.createdAt);

                Share.share(
                  '🔮 FalNova\'da kahve falıma baktırdım!\n\n'
                  '📅 $formattedDate tarihli falım:\n\n'
                  '${reading.interpretation}\n\n'
                  '✨ Sen de falına baktırmak istersen:\n'
                  'https://falnova.app',
                );
              });
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final futureReadings =
              ref.watch(fortuneRepositoryProvider.notifier).getFortuneHistory();

          return FutureBuilder<List<FortuneReading>?>(
            future: futureReadings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              final readings = snapshot.data;
              if (readings == null) {
                return const Center(child: Text('Fal bulunamadı'));
              }

              final reading = readings.firstWhere(
                (r) => r.id == readingId,
                orElse: () => throw Exception('Fal bulunamadı'),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: reading.imageUrl != null
                            ? Image.network(
                                reading.imageUrl!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: 300,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported,
                                    size: 64),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                  Icons.coffee,
                                  color: Colors.brown.shade800,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kahve Falı Yorumu',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.brown.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              reading.interpretation,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.brown.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tarih: ${reading.createdAt.toString().split(' ')[0]}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.brown.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
