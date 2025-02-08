import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/repositories/notification/notification_repository.dart';
import 'package:falnova/backend/services/notification/notification_service.dart';
import 'package:falnova/backend/models/notification/notification.dart' as model;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends HookConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'read_all':
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
                            content: Text(
                                'Tüm bildirimler okundu olarak işaretlendi')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Bildirimler işaretlenirken bir hata oluştu')),
                      );
                    }
                  }
                  break;
                case 'delete_all':
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Bildirimleri Sil'),
                      content: const Text(
                          'Tüm bildirimler silinecek. Emin misiniz?'),
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
                          const SnackBar(
                              content: Text('Tüm bildirimler silindi')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Bildirimler silinirken bir hata oluştu')),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8),
                    Text('Tümünü Oku'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Tümünü Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifications.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationRepositoryProvider);
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz bildiriminiz yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationRepositoryProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) async {
                    try {
                      // Önce state'i güncelle
                      final updatedList =
                          List<model.Notification>.from(notifications)
                            ..removeWhere((n) => n.id == notification.id);
                      ref
                          .read(notificationRepositoryProvider.notifier)
                          .updateNotifications(updatedList);

                      // Sonra veritabanından sil
                      await ref
                          .read(notificationServiceProvider)
                          .deleteNotification(notification.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bildirim silindi')),
                        );
                      }
                    } catch (e) {
                      // Hata durumunda listeyi yeniden yükle
                      ref
                          .read(notificationRepositoryProvider.notifier)
                          .loadNotifications();

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
                    leading: Icon(
                      notification.type == 'coffee_reminder'
                          ? Icons.coffee
                          : Icons.star,
                      color:
                          notification.isRead ? Colors.grey : Colors.deepPurple,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm')
                              .format(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!notification.isRead) {
                        ref
                            .read(notificationRepositoryProvider.notifier)
                            .markAsRead(notification.id);
                      }

                      // Bildirim türüne göre ilgili ekrana yönlendir
                      if (notification.type == 'coffee_reminder') {
                        context.go('/fortune');
                      } else if (notification.type == 'horoscope_reminder') {
                        context.go('/horoscope');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu: $error'),
        ),
      ),
    );
  }
}
