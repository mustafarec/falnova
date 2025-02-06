import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/repositories/notification/notification_repository.dart';
import 'package:falnova/backend/services/notification/notification_service.dart';
import 'package:get/get.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationRepositoryProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () async {
              try {
                await ref
                    .read(notificationServiceProvider)
                    .markAllNotificationsAsRead();
                ref
                    .read(notificationRepositoryProvider.notifier)
                    .loadNotifications();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Tüm bildirimler okundu olarak işaretlendi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Bildirimler işaretlenirken bir hata oluştu')),
                  );
                }
              }
            },
            tooltip: 'Tümünü Okundu İşaretle',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bildirimleri Sil'),
                  content:
                      const Text('Tüm bildirimler silinecek. Emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );

              if (result == true && context.mounted) {
                try {
                  await ref
                      .read(notificationServiceProvider)
                      .deleteAllNotifications();
                  ref
                      .read(notificationRepositoryProvider.notifier)
                      .loadNotifications();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tüm bildirimler silindi')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Bildirimler silinirken bir hata oluştu')),
                    );
                  }
                }
              }
            },
            tooltip: 'Tümünü Sil',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(notificationRepositoryProvider.notifier)
            .loadNotifications(),
        child: notifications.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(
                child: Text('Henüz bildirim bulunmuyor'),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    try {
                      await ref
                          .read(notificationServiceProvider)
                          .deleteNotification(notification.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bildirim silindi')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Bildirim silinirken bir hata oluştu')),
                        );
                      }
                    }
                  },
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    onTap: () {
                      // Bildirim tipine göre yönlendirme yap
                      if (notification.type == 'coffee') {
                        Get.toNamed('/coffee-reading',
                            arguments: {'id': notification.id});
                      } else if (notification.type == 'horoscope') {
                        Get.toNamed('/horoscope',
                            arguments: {'id': notification.id});
                      } else {
                        Get.toNamed('/home');
                      }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!notification.isRead)
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () async {
                              try {
                                await ref
                                    .read(notificationServiceProvider)
                                    .markAsRead(notification.id);
                                ref
                                    .read(
                                        notificationRepositoryProvider.notifier)
                                    .loadNotifications();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Bildirim işaretlenirken bir hata oluştu'),
                                    ),
                                  );
                                }
                              }
                            },
                            tooltip: 'Okundu İşaretle',
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Bildirimi Sil'),
                                content: const Text(
                                    'Bu bildirim silinecek. Emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );

                            if (result == true && context.mounted) {
                              try {
                                await ref
                                    .read(notificationServiceProvider)
                                    .deleteNotification(notification.id);
                                ref
                                    .read(
                                        notificationRepositoryProvider.notifier)
                                    .loadNotifications();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Bildirim silindi')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Bildirim silinirken bir hata oluştu'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          tooltip: 'Sil',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Bir hata oluştu: $error'),
          ),
        ),
      ),
    );
  }
}
