import 'dart:io';
import 'package:falnova/backend/models/fortune/palm_reading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:falnova/backend/services/ai/ai_service.dart';
import 'package:falnova/backend/services/storage/storage_service.dart';
import 'package:falnova/backend/services/palm_detection_service.dart';
import 'package:falnova/core/services/palm_validation_service.dart';
import 'dart:convert';
import 'package:vector_math/vector_math.dart' show Vector2;

part 'palm_analysis_service.g.dart';

@riverpod
class PalmAnalysisService extends _$PalmAnalysisService {
  late final AiService _aiService;
  late final StorageService _storageService;
  late final PalmDetectionService _palmDetectionService;
  final _picker = ImagePicker();

  @override
  Future<void> build() async {
    _aiService = ref.watch(aiServiceProvider);
    _storageService = ref.watch(storageServiceProvider);
    _palmDetectionService = PalmDetectionService();
  }

  Future<PalmReading?> analyzePalmImage(
      String userId, ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Görüntü doğrulama
      final isValidImage = await PalmValidationService.isPalmImage(image.path);
      if (!isValidImage) {
        throw Exception(PalmValidationService.getValidationErrorMessage());
      }

      // El çizgilerini tespit et
      final lineCoordinates =
          await _palmDetectionService.extractPalmLines(image.path);

      // Resmi base64'e çevir ve AI analizi yap
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      const prompt =
          '''Bu bir el falı fotoğrafı. Sen deneyimli bir el falı uzmanısın.
      
      Lütfen gösterilen avuç içindeki çizgileri detaylı bir şekilde analiz et:
      1. Önce çizgilerin konumlarını ve şekillerini belirle
      2. Her çizginin özelliklerini (uzunluk, derinlik, kesintiler, dallanmalar) not et
      3. Bu özelliklere dayanarak yorumunu yap
      
      Yanıtını şu bölümlere ayır ve her bölüm için olumlu, motive edici ve yapıcı yorumlar yap:
      
      YAŞAM ÇİZGİSİ (Life Line):
      - Başparmağın yanından başlayıp bileğe doğru inen çizgi
      - Sağlık, yaşam enerjisi ve yaşam kalitesini gösterir
      
      KALP ÇİZGİSİ (Heart Line):
      - Serçe parmağının altından başlayıp işaret parmağına doğru uzanan çizgi
      - Duygusal yaşam, ilişkiler ve sevgi kapasitesini gösterir
      
      KAFA ÇİZGİSİ (Head Line):
      - İşaret ve orta parmak arasından başlayan yatay çizgi
      - Düşünce yapısı, öğrenme ve karar verme yeteneğini gösterir
      
      KADER ÇİZGİSİ (Fate Line):
      - Bilekten orta parmağa doğru uzanan dikey çizgi
      - Kariyer, başarı ve hayat yolculuğunu gösterir
      
      Her yorumun sonunda kişiye özel, motive edici bir tavsiye ver.
      Yanıtını Türkçe olarak ver ve profesyonel, güven verici bir üslup kullan.''';

      final aiAnalysis =
          await _aiService.generateContentWithImage(prompt, base64Image);

      // Yorumları oluştur
      final interpretations =
          _generateInterpretations(lineCoordinates, aiAnalysis: aiAnalysis);

      // Resmi kaydet
      final imageUrl = await _storageService.uploadPalmImage(image.path);

      return PalmReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        lineCoordinates: lineCoordinates,
        interpretations: interpretations,
        aiAnalysis: aiAnalysis,
        isProcessed: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _generateInterpretations(Map<String, List<Vector2>> lines,
      {String? aiAnalysis}) {
    final Map<String, String> interpretations = {};

    // AI analizini bölümlere ayır
    if (aiAnalysis != null && aiAnalysis.isNotEmpty) {
      // Önce satır satır böl
      final lines = aiAnalysis.split('\n');
      String currentSection = '';
      String currentContent = '';

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        if (line.toUpperCase().contains('YAŞAM ÇİZGİSİ') ||
            line.toUpperCase().contains('KALP ÇİZGİSİ') ||
            line.toUpperCase().contains('KAFA ÇİZGİSİ') ||
            line.toUpperCase().contains('KADER ÇİZGİSİ')) {
          // Önceki bölümü kaydet
          if (currentSection.isNotEmpty && currentContent.isNotEmpty) {
            interpretations[currentSection] = currentContent.trim();
          }
          // Yeni bölümü başlat
          if (line.toUpperCase().contains('YAŞAM ÇİZGİSİ')) {
            currentSection = 'lifeLine';
          } else if (line.toUpperCase().contains('KALP ÇİZGİSİ')) {
            currentSection = 'heartLine';
          } else if (line.toUpperCase().contains('KAFA ÇİZGİSİ')) {
            currentSection = 'headLine';
          } else if (line.toUpperCase().contains('KADER ÇİZGİSİ')) {
            currentSection = 'fateLine';
          }
          currentContent = '';
        } else if (currentSection.isNotEmpty) {
          // İçeriği biriktir
          currentContent += line + ' ';
        }
      }
      // Son bölümü kaydet
      if (currentSection.isNotEmpty && currentContent.isNotEmpty) {
        interpretations[currentSection] = currentContent.trim();
      }
    }

    // Eğer AI analizi boşsa veya bölüm bulunamadıysa, varsayılan mesajları kullan
    if (!interpretations.containsKey('lifeLine')) {
      interpretations['lifeLine'] =
          'Yaşam çizginiz analiz edilemedi. Lütfen daha net bir fotoğraf çekmeyi deneyin.';
    }
    if (!interpretations.containsKey('heartLine')) {
      interpretations['heartLine'] =
          'Kalp çizginiz analiz edilemedi. Lütfen daha net bir fotoğraf çekmeyi deneyin.';
    }
    if (!interpretations.containsKey('headLine')) {
      interpretations['headLine'] =
          'Kafa çizginiz analiz edilemedi. Lütfen daha net bir fotoğraf çekmeyi deneyin.';
    }
    if (!interpretations.containsKey('fateLine')) {
      interpretations['fateLine'] =
          'Kader çizginiz analiz edilemedi. Lütfen daha net bir fotoğraf çekmeyi deneyin.';
    }

    return interpretations;
  }
}
