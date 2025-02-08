import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class FortuneGrid extends ConsumerWidget {
  const FortuneGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildListDelegate(
        [
          // Kahve Falı
          _FortuneCard(
            title: 'Kahve Falı',
            description: 'Fincanını çek, falına bak',
            icon: Icons.coffee,
            color: Colors.brown,
            onTap: () => context.push('/fortune'),
          ),

          // El Falı
          _FortuneCard(
            title: 'El Falı',
            description: 'El çizgilerinden geleceğini öğren',
            icon: Icons.back_hand,
            color: Colors.orange,
            onTap: () => context.push('/fortune/palm'),
          ),

          // Yıldız Falı
          _FortuneCard(
            title: 'Yıldız Falı',
            description: 'Yıldızların rehberliğinde',
            icon: Icons.auto_awesome,
            color: Colors.purple,
            onTap: () => context.push('/astrology/star-fortune'),
            isComingSoon: false,
          ),

          // Burç Uyumluluğu
          _FortuneCard(
            title: 'Burç Uyumluluğu',
            description: 'Burçların uyumunu keşfet',
            icon: Icons.favorite,
            color: Colors.pink,
            onTap: () => context.push('/compatibility'),
            isComingSoon: false,
          ),

          // Tarot Falı
          _FortuneCard(
            title: 'Tarot Falı',
            description: 'Kartların sırrını keşfet',
            icon: Icons.style,
            color: Colors.indigo,
            onTap: () => context.push('/tarot'),
            isComingSoon: true,
          ),

          // Rüya Tabiri
          _FortuneCard(
            title: 'Rüya Tabiri',
            description: 'Rüyalarını yorumla',
            icon: Icons.cloud,
            color: Colors.teal,
            onTap: () => context.push('/dream'),
            isComingSoon: true,
          ),
        ],
      ),
    );
  }
}

class _FortuneCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _FortuneCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                textAlign: TextAlign.center,
              ),
              if (isComingSoon) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Yakında',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
