import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:falnova/backend/repositories/fortune/fortune_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:falnova/core/services/image_validation_service.dart';

class FortuneScreen extends HookConsumerWidget {
  const FortuneScreen({super.key});

  static const primaryColor = Colors.brown;
  static const secondaryColor = Colors.brown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = useState<File?>(null);
    final isLoading = useState(false);
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    }

    Future<void> interpretFortune() async {
      if (selectedImage.value == null) return;

      try {
        isLoading.value = true;
        final repository = ref.read(fortuneRepositoryProvider.notifier);

        // Görüntü doğrulama
        final isValidImage = await ImageValidationService.isCoffeeCupImage(
            selectedImage.value!.path);
        if (!isValidImage) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(ImageValidationService.getValidationErrorMessage()),
                backgroundColor: Colors.red,
              ),
            );
          }
          isLoading.value = false;
          selectedImage.value = null;
          return;
        }

        // Resmi base64'e çevir
        final bytes = await selectedImage.value!.readAsBytes();
        final base64Image = base64Encode(bytes);

        final reading = await repository.getFortuneTelling(
          base64Image,
          selectedImage.value!.path,
        );

        if (context.mounted) {
          context.push('/fortune/reading/${reading.id}');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
        selectedImage.value = null;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Kahve Falı',
        showBackButton: false,
        showNotification: true,
        backgroundColor: Colors.brown.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/fortune/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.brown.shade800,
                        Colors.brown.shade600,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fincanını Seç',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fincanının içini net görebileceğimiz bir fotoğraf çek veya seç',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fotoğraf Seçimi veya Önizleme
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: selectedImage.value == null
                      ? Column(
                          children: [
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.coffee,
                                    size: 64,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Fotoğraf Yükle',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () =>
                                            pickImage(ImageSource.camera),
                                        icon: const Icon(Icons.camera_alt),
                                        label: const Text('Fotoğraf Çek'),
                                      ),
                                      const SizedBox(width: 16),
                                      FilledButton.icon(
                                        onPressed: () =>
                                            pickImage(ImageSource.gallery),
                                        icon: const Icon(Icons.photo_library),
                                        label: const Text('Galeriden Seç'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tips_and_updates,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Fotoğraf Çekme İpuçları',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTipItem(
                                      icon: Icons.light_mode,
                                      text:
                                          'İyi aydınlatılmış bir ortamda çekim yapın',
                                      theme: theme,
                                    ),
                                    _buildTipItem(
                                      icon: Icons.camera_enhance,
                                      text:
                                          'Fincanın içini net gösterecek bir açı seçin',
                                      theme: theme,
                                    ),
                                    _buildTipItem(
                                      icon: Icons.coffee,
                                      text:
                                          'Fincanın tamamen boşalmış olduğundan emin olun',
                                      theme: theme,
                                    ),
                                    _buildTipItem(
                                      icon: Icons.center_focus_strong,
                                      text:
                                          'Fincan desenlerinin net görünmesine dikkat edin',
                                      theme: theme,
                                    ),
                                    _buildTipItem(
                                      icon: Icons.photo_size_select_large,
                                      text:
                                          'Fincanı yakından çekin, gereksiz boşluk bırakmayın',
                                      theme: theme,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.file(
                                  selectedImage.value!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton.filled(
                                  onPressed: () => selectedImage.value = null,
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: FilledButton.icon(
                                  onPressed: interpretFortune,
                                  icon: const Icon(Icons.auto_awesome),
                                  label: const Text('Falımı Yorumla'),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Diğer Fal Türleri',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: InkWell(
                          onTap: () => context.push('/fortune/palm'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.back_hand,
                                    color: theme.colorScheme.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'El Falı',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'El çizgilerinizden geleceğinizi öğrenin',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .textTheme.bodyMedium?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading.value)
            Container(
              color: Colors.black54,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
