import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/backend/services/fortune/palm_analysis_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PalmReadingScreen extends ConsumerStatefulWidget {
  const PalmReadingScreen({super.key});

  static const primaryColor = Colors.orange;
  static const secondaryColor = Colors.deepOrange;

  @override
  ConsumerState<PalmReadingScreen> createState() => _PalmReadingScreenState();
}

class _PalmReadingScreenState extends ConsumerState<PalmReadingScreen> {
  bool _isAnalyzing = false;
  String? _errorMessage;
  Map<String, String>? _interpretations;
  String? _selectedImage;
  String? _selectedLine;

  Future<void> _startPalmReading(ImageSource source) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final palmReading = await ref
          .read(palmAnalysisServiceProvider.notifier)
          .analyzePalmImage('user123', source);

      if (palmReading != null) {
        setState(() {
          _selectedImage = palmReading.imageUrl;
          _interpretations = palmReading.interpretations;
          _isAnalyzing = false;
        });
      } else {
        // Kullanıcı seçimden vazgeçti
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isAnalyzing = false;
      });
      // Hata mesajını göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Tamam',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Widget dispose edildiğinde yükleme durumunu sıfırla
    setState(() {
      _isAnalyzing = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PalmReadingScreen.primaryColor,
        primary: PalmReadingScreen.primaryColor,
        secondary: PalmReadingScreen.secondaryColor,
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'El Falı',
        backgroundColor: PalmReadingScreen.primaryColor.shade800,
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
                        PalmReadingScreen.primaryColor.shade800,
                        PalmReadingScreen.primaryColor.shade600,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avuç İçini Göster',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Avuç içinizin net bir fotoğrafını çekin veya seçin',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ana İçerik
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Fotoğraf Alanı
                      if (_selectedImage == null) ...[
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
                                Icons.back_hand,
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
                                    onPressed: _isAnalyzing
                                        ? null
                                        : () => _startPalmReading(
                                            ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Fotoğraf Çek'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  FilledButton.icon(
                                    onPressed: _isAnalyzing
                                        ? null
                                        : () => _startPalmReading(
                                            ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Galeriden Seç'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // İpuçları
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
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
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
                                  text: 'Avuç içinizi düz ve net gösterin',
                                  theme: theme,
                                ),
                                _buildTipItem(
                                  icon: Icons.back_hand,
                                  text:
                                      'El çizgilerinizin net görünmesine dikkat edin',
                                  theme: theme,
                                ),
                                _buildTipItem(
                                  icon: Icons.center_focus_strong,
                                  text: 'Tüm avuç içiniz kare içinde olsun',
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else
                        Stack(
                          children: [
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filled(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _interpretations = null;
                                    _selectedLine = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Yorumlar
                      if (_interpretations != null) ...[
                        Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'El Falı Yorumunuz',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                for (var entry
                                    in _interpretations!.entries) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.gesture,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                switch (entry.key) {
                                                  'lifeLine' => 'Yaşam Çizgisi',
                                                  'heartLine' => 'Kalp Çizgisi',
                                                  'headLine' => 'Akıl Çizgisi',
                                                  'fateLine' => 'Kader Çizgisi',
                                                  _ => entry.key,
                                                },
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          entry.value
                                              .replaceAll('*', '')
                                              .replaceAll('**', ''),
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            height: 1.6,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fotoğraf Analiz Ediliyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
