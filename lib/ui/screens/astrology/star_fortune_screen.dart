import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

class StarFortuneScreen extends HookConsumerWidget {
  const StarFortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Yıldız Falı',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık ve Açıklama
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yıldızların Rehberliğinde',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Doğum haritanıza göre özel yorumlar ve tahminler',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Grid Menü
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // Doğum Haritası
                _MenuCard(
                  title: 'Doğum Haritası',
                  subtitle: 'Gezegenlerin konumları\nve etkileri',
                  icon: Icons.public,
                  color: Colors.purple,
                  isActive: true,
                  onTap: () => context.push('/birth-chart'),
                ),

                // Transit Gezegenler
                _MenuCard(
                  title: 'Transit Gezegenler',
                  subtitle: 'Günlük gezegen\nhareketleri',
                  icon: Icons.sync,
                  color: Colors.purple,
                  isActive: true,
                  onTap: () => context.push('/transits'),
                ),

                // Açı Hesaplamaları
                _MenuCard(
                  title: 'Açı Hesaplamaları',
                  subtitle: 'Gezegenler arası açılar',
                  icon: Icons.architecture,
                  color: Colors.purple,
                  isActive: true,
                  onTap: () => context.push('/astrology/aspect-calculations'),
                ),

                // Ev Sistemleri
                _MenuCard(
                  title: 'Ev Sistemleri',
                  subtitle: 'Yaşam alanlarınız ve\netkileri',
                  icon: Icons.home,
                  color: Colors.purple,
                  isActive: true,
                  onTap: () => context.push('/astrology/house-systems'),
                ),

                // Yükselen/Ay Yükselen
                _MenuCard(
                  title: 'Yükselen/Ay Yükselen',
                  subtitle: 'Hassas hesaplama ve\ndekan analizi',
                  icon: Icons.person,
                  color: Colors.purple,
                  isActive: true,
                  onTap: () => context.push('/astrology/ascendant'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isActive ? 0.8 : 0.5),
                color.withOpacity(isActive ? 0.6 : 0.3),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              if (!isActive) ...[
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
