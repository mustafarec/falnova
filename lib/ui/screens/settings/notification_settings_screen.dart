import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:falnova/backend/models/notification/notification_settings.dart';
import 'package:falnova/backend/repositories/notification/notification_repository.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: settings.when(
        data: (settings) {
          if (settings == null) {
            return _ErrorState(
              message: 'Bildirim ayarları bulunamadı',
              onRetry: () => ref.invalidate(notificationSettingsProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await ref
                    .read(notificationSettingsProvider.notifier)
                    .refreshSettings();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Yenileme başarısız: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _CoffeeFortuneNotificationCard(settings: settings, ref: ref),
                const SizedBox(height: 16),
                _HoroscopeNotificationCard(settings: settings, ref: ref),
              ],
            ),
          );
        },
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Bildirim ayarları bulunamadı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.discreteCircle(
            color: Colors.deepPurple,
            size: 40,
            secondRingColor: Colors.purple,
            thirdRingColor: Colors.purple.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bildirim ayarları yükleniyor...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoffeeFortuneNotificationCard extends ConsumerWidget {
  const _CoffeeFortuneNotificationCard({
    required this.settings,
    required this.ref,
  });

  final NotificationSettings settings;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.coffee, color: Color(0xFF9C27B0)),
                SizedBox(width: 8),
                Text(
                  'Kahve Falı Bildirimleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bildirimleri Etkinleştir'),
              subtitle: const Text('Kahve falı baktırmayı unutmayın'),
              value: settings.coffeeReminderEnabled,
              onChanged: (value) async {
                await ref
                    .read(notificationSettingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(coffeeReminderEnabled: value),
                    );
              },
            ),
            if (settings.coffeeReminderEnabled) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Hatırlatma Zamanları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _ReminderTimeChips(settings: settings, ref: ref),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderTimeChips extends ConsumerWidget {
  const _ReminderTimeChips({
    required this.settings,
    required this.ref,
  });

  final NotificationSettings settings;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...settings.coffeeReminderTime.map(
          (time) => Chip(
            label: Text(time),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () async {
              final newTimes = List<String>.from(settings.coffeeReminderTime)
                ..remove(time);
              await ref
                  .read(notificationSettingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(coffeeReminderTime: newTimes),
                  );
            },
          ),
        ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Zaman Ekle'),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (time != null) {
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              if (!settings.coffeeReminderTime.contains(timeStr)) {
                final newTimes = List<String>.from(settings.coffeeReminderTime)
                  ..add(timeStr);
                await ref
                    .read(notificationSettingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(coffeeReminderTime: newTimes),
                    );
              }
            }
          },
        ),
      ],
    );
  }
}

class _HoroscopeNotificationCard extends ConsumerWidget {
  const _HoroscopeNotificationCard({
    required this.settings,
    required this.ref,
  });

  final NotificationSettings settings;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF9C27B0)),
                SizedBox(width: 8),
                Text(
                  'Burç Yorumu Bildirimleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bildirimleri Etkinleştir'),
              subtitle: const Text('Her gün burç yorumunuzu alın'),
              value: settings.horoscopeReminderEnabled,
              onChanged: (value) async {
                await ref
                    .read(notificationSettingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(horoscopeReminderEnabled: value),
                    );
              },
            ),
            if (settings.horoscopeReminderEnabled) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Hatırlatma Zamanları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...settings.horoscopeReminderTime.map(
                    (time) => Chip(
                      label: Text(time),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () async {
                        final newTimes =
                            List<String>.from(settings.horoscopeReminderTime)
                              ..remove(time);
                        await ref
                            .read(notificationSettingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(
                                  horoscopeReminderTime: newTimes),
                            );
                      },
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Zaman Ekle'),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {
                        final timeStr =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        if (!settings.horoscopeReminderTime.contains(timeStr)) {
                          final newTimes =
                              List<String>.from(settings.horoscopeReminderTime)
                                ..add(timeStr);
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .updateSettings(
                                settings.copyWith(
                                    horoscopeReminderTime: newTimes),
                              );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
