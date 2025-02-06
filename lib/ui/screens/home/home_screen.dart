import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/repositories/notification/notification_repository.dart';
import 'package:badges/badges.dart' as badges;
import 'package:falnova/backend/services/supabase_service.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationRepositoryProvider);
    final unreadCount = notifications.whenOrNull(
          data: (notifications) => notifications.where((n) => !n.isRead).length,
        ) ??
        0;

    final supabase = ref.read(supabaseServiceProvider);
    final user = supabase.client.auth.currentUser;
    final firstName = user?.userMetadata?['first_name'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FalNOVA'),
        actions: [
          IconButton(
            icon: badges.Badge(
              showBadge: unreadCount > 0,
              badgeContent: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hoş geldin $firstName',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kahve falı ve burç yorumlarınız için alt menüyü kullanabilirsiniz.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.coffee,
                        size: 48,
                        color: Colors.brown,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kahve Falı',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fincanınızın fotoğrafını yükleyin, yapay zeka destekli falınızı hemen öğrenin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.go('/fortune'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Fal Baktır'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Günlük Burç Yorumu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Burcunuzu seçin, günlük yıldız haritanızı ve yorumunuzu öğrenin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.go('/horoscope'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Yorumları Gör'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.stars,
                        size: 48,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Yıldız Falı',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yıldızların size özel mesajlarını keşfedin, geleceğinizi aydınlatın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Yakında'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Premium Store',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Özel fallar, detaylı yorumlar ve daha fazlası için premium özellikleri keşfedin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Yakında'),
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
}
