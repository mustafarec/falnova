import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:logger/logger.dart';

final _logger = Logger();

Future<void> initSweph(List<String> files) async {
  try {
    final dir = await getApplicationSupportDirectory();
    final epheDir = Directory('${dir.path}/ephe');
    if (!epheDir.existsSync()) {
      epheDir.createSync();
    }

    for (final file in files) {
      final fileName = file.split('/').last;
      final targetFile = File('${epheDir.path}/$fileName');

      if (!targetFile.existsSync()) {
        try {
          // Assets'ten yükleme
          final assetPath = 'assets/ephe/$fileName';
          final data = await rootBundle.load(assetPath);
          await targetFile.writeAsBytes(data.buffer.asUint8List());
          _logger.i('Dosya assets\'ten yüklendi: $fileName');
        } catch (assetError) {
          _logger.e('Asset yüklenemedi: $assetError');
          throw Exception('Asset bulunamadı: $fileName');
        }
      }
    }
  } catch (e) {
    _logger.e('Ephemeris dosyaları yüklenirken hata: $e');
    rethrow;
  }
}
