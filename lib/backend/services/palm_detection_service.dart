import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

class PalmDetectionService {
  final _logger = Logger();

  Future<Map<String, List<Vector2>>> extractPalmLines(String imagePath) async {
    try {
      // Load and process image
      final File imageFile = File(imagePath);
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());

      if (image == null) {
        throw Exception('Fotoğraf yüklenemedi. Lütfen tekrar deneyin.');
      }

      // Extract palm lines from the image
      final palmLines = _extractLinesFromImage(image);

      return palmLines;
    } catch (e) {
      _logger.e('El çizgilerini tespit ederken hata oluştu: $e');
      throw Exception(
          'El çizgilerini analiz ederken bir sorun oluştu. Lütfen tekrar deneyin.');
    }
  }

  Map<String, List<Vector2>> _extractLinesFromImage(img.Image image) {
    // Görüntüyü gri tonlamaya çevir
    final grayImage = img.grayscale(image);

    final lifeLine = <Vector2>[];
    final heartLine = <Vector2>[];
    final headLine = <Vector2>[];
    final fateLine = <Vector2>[];

    // Basit eşikleme ile çizgileri tespit et
    for (int y = 0; y < grayImage.height; y++) {
      for (int x = 0; x < grayImage.width; x++) {
        final pixel = grayImage.getPixel(x, y);
        final brightness = img.getLuminance(pixel);

        // Koyu pikselleri çizgi olarak kabul et
        if (brightness < 150) {
          // Koordinatları 0-1 aralığına normalize et
          final normalizedX = x / grayImage.width;
          final normalizedY = y / grayImage.height;
          final point = Vector2(normalizedX, normalizedY);

          if (_isInLifeLineRegion(x, y, grayImage.width, grayImage.height)) {
            lifeLine.add(point);
          } else if (_isInHeartLineRegion(
              x, y, grayImage.width, grayImage.height)) {
            heartLine.add(point);
          } else if (_isInHeadLineRegion(
              x, y, grayImage.width, grayImage.height)) {
            headLine.add(point);
          } else if (_isInFateLineRegion(
              x, y, grayImage.width, grayImage.height)) {
            fateLine.add(point);
          }
        }
      }
    }

    // Çizgileri basitleştir (her N pikselde bir nokta al)
    const simplifyFactor = 5;
    return {
      'lifeLine': _simplifyLine(lifeLine, simplifyFactor),
      'heartLine': _simplifyLine(heartLine, simplifyFactor),
      'headLine': _simplifyLine(headLine, simplifyFactor),
      'fateLine': _simplifyLine(fateLine, simplifyFactor),
    };
  }

  List<Vector2> _simplifyLine(List<Vector2> points, int factor) {
    if (points.isEmpty) return points;
    final simplified = <Vector2>[];
    for (var i = 0; i < points.length; i += factor) {
      simplified.add(points[i]);
    }
    return simplified;
  }

  bool _isInLifeLineRegion(int x, int y, int width, int height) {
    // Yaşam çizgisi başparmağın yanından başlar ve bileğe doğru iner
    return x < width * 0.5 && y > height * 0.4 && y < height * 0.9;
  }

  bool _isInHeartLineRegion(int x, int y, int width, int height) {
    // Kalp çizgisi serçe parmağının altından başlar ve işaret parmağına doğru uzanır
    return y < height * 0.5 && x > width * 0.3 && x < width * 0.9;
  }

  bool _isInHeadLineRegion(int x, int y, int width, int height) {
    // Kafa çizgisi işaret parmağı ile orta parmak arasından başlar
    return y > height * 0.3 &&
        y < height * 0.6 &&
        x > width * 0.3 &&
        x < width * 0.8;
  }

  bool _isInFateLineRegion(int x, int y, int width, int height) {
    // Kader çizgisi bilekten başlar ve orta parmağa doğru uzanır
    return x > width * 0.4 && x < width * 0.6 && y > height * 0.3;
  }
}
