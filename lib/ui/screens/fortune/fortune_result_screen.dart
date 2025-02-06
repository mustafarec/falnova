import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:falnova/backend/models/fortune/fortune_models.dart';
import 'package:falnova/backend/repositories/fortune/fortune_repository.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

class FortuneResultScreen extends ConsumerWidget {
  final String readingId;

  const FortuneResultScreen({super.key, required this.readingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Kahve Falı Yorumu',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              'Kahve falımı FalNova uygulamasında baktırdım! Sen de denemek ister misin?\n\nhttps://falnova.app',
            ),
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
                    ClipRRect(
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
                    const SizedBox(height: 24),
                    Text(
                      reading.interpretation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tarih: ${reading.createdAt.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
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
