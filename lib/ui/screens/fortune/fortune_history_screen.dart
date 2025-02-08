import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/repositories/fortune/fortune_repository.dart';
import 'package:falnova/backend/models/fortune/fortune_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

final fortuneHistoryProvider =
    FutureProvider.autoDispose<List<FortuneReading>>((ref) async {
  final repository = ref.watch(fortuneRepositoryProvider.notifier);
  return await repository.getFortuneHistory();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final dateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

final filteredReadingsProvider =
    StateNotifierProvider<FilteredReadingsNotifier, List<FortuneReading>>(
        (ref) {
  return FilteredReadingsNotifier(ref);
});

class FortuneHistoryScreen extends ConsumerStatefulWidget {
  const FortuneHistoryScreen({super.key});

  @override
  ConsumerState<FortuneHistoryScreen> createState() =>
      _FortuneHistoryScreenState();
}

class _FortuneHistoryScreenState extends ConsumerState<FortuneHistoryScreen> {
  final Set<String> _dismissedItems = {};

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr_TR');

    final fortuneHistoryAsync = ref.watch(fortuneHistoryProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Fal Geçmişim',
        showBackButton: true,
        backgroundColor: Colors.brown.shade800,
      ),
      body: fortuneHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu: $error'),
        ),
        data: (readings) {
          if (readings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.coffee,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz Fal Geçmişiniz Yok',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Kahve falı baktırarak fallarınızı burada görüntüleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/fortune'),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Fal Baktır'),
                  ),
                ],
              ),
            );
          }

          final visibleReadings =
              readings.where((r) => !_dismissedItems.contains(r.id)).toList();

          if (visibleReadings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.coffee,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz Fal Geçmişiniz Yok',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Kahve falı baktırarak fallarınızı burada görüntüleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/fortune'),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Fal Baktır'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visibleReadings.length,
            itemBuilder: (context, index) {
              final reading = visibleReadings[index];
              return Dismissible(
                key: ValueKey(reading.id),
                direction: DismissDirection.endToStart,
                background: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.red,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                onDismissed: (direction) async {
                  final deletedReading = reading;

                  // Yerel state'i güncelle
                  setState(() {
                    _dismissedItems.add(reading.id);
                  });

                  // Silme işlemini gerçekleştir ve snackbar göster
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Fal silindi'),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Geri Al',
                        onPressed: () async {
                          try {
                            // Önce veritabanı işlemini gerçekleştir
                            await ref
                                .read(fortuneRepositoryProvider.notifier)
                                .restoreFortune(deletedReading);

                            // İşlem başarılı olursa UI'ı güncelle
                            setState(() {
                              _dismissedItems.remove(deletedReading.id);
                            });

                            // Listeyi yenile
                            ref.invalidate(fortuneHistoryProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Fal geri yüklenirken hata oluştu'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );

                  // Silme işlemini gerçekleştir
                  try {
                    await ref
                        .read(fortuneRepositoryProvider.notifier)
                        .deleteFortune(deletedReading);
                  } catch (e) {
                    // Hata durumunda yerel state'i geri al
                    setState(() {
                      _dismissedItems.remove(reading.id);
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fal silinirken hata oluştu'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: _FortuneCard(reading: reading),
              );
            },
          );
        },
      ),
    );
  }
}

class _FortuneCard extends StatelessWidget {
  final FortuneReading reading;

  const _FortuneCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/fortune/reading/${reading.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kahve fincanı fotoğrafı
            if (reading.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: reading.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

            // Fal detayları
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(reading.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (reading.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Premium',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Yorumun ilk birkaç satırı
                  Text(
                    reading.interpretation.split('\n').first,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Detay butonu
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/fortune/reading/${reading.id}'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detayları Görüntüle'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filtreleme için StateNotifier
class FilteredReadingsNotifier extends StateNotifier<List<FortuneReading>> {
  final Ref ref;

  FilteredReadingsNotifier(this.ref) : super([]) {
    _initialize();
  }

  void _initialize() {
    ref.listen(fortuneHistoryProvider, (_, next) {
      if (next.hasValue) {
        state = next.value ?? [];
      }
    });
  }

  void applyFilters(String query, DateTimeRange? dateRange) {
    final allReadings = ref.read(fortuneHistoryProvider).value ?? [];
    state = allReadings.where((reading) {
      // Metin araması
      final matchesSearch = query.isEmpty ||
          reading.interpretation.toLowerCase().contains(query.toLowerCase());

      // Tarih filtresi
      final matchesDate = dateRange == null ||
          (reading.createdAt.isAfter(dateRange.start) &&
              reading.createdAt
                  .isBefore(dateRange.end.add(const Duration(days: 1))));

      return matchesSearch && matchesDate;
    }).toList();
  }
}
