import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () => context.go('/settings/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Bildirim Ayarları'),
            onTap: () => context.go('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Premium Üyelik'),
            onTap: () {
              // TODO: Premium üyelik sayfasına git
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium üyelik yakında eklenecek'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Hakkında'),
            onTap: () {
              // TODO: Hakkında sayfasına git
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hakkında sayfası yakında eklenecek'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
