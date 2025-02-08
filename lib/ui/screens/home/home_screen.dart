import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/ui/widgets/home/hero_section.dart';
import 'package:falnova/ui/widgets/home/fortune_grid.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'FalNova',
        showBackButton: false,
        showNotification: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: HeroSection(),
            ),

            // Grid Categories
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: FortuneGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
