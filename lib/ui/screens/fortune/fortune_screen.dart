import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:badges/badges.dart' as badges;
import 'package:falnova/backend/repositories/fortune/fortune_repository.dart';
import 'package:falnova/backend/repositories/notification/notification_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:falnova/core/services/image_validation_service.dart';

class FortuneScreen extends HookConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = useState<File?>(null);
    final isLoading = useState(false);
    final notifications = ref.watch(notificationRepositoryProvider);
    final unreadCount = notifications.whenOrNull(
          data: (notifications) => notifications.where((n) => !n.isRead).length,
        ) ??
        0;

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
        showBackButton: true,
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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/fortune/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedImage.value == null) ...[
                  const Icon(
                    Icons.coffee,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Fincan Fotoğrafını Yükleyin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fincanınızın içini net görebileceğimiz bir fotoğraf çekin veya seçin',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            selectedImage.value!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => selectedImage.value = null,
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: isLoading.value ? null : interpretFortune,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Falımı Yorumla'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Fotoğraf Çek'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 48),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeriden Seç'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
}
