import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final _supabase = Supabase.instance.client;
  final _bucketName = 'fortune-images';

  Future<String> uploadFortuneImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
      final filePath = 'fortune-readings/$fileName';

      // Dosyayı yükle
      final response = await _supabase.storage.from(_bucketName).upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      if (response.isEmpty) {
        throw Exception('Dosya yüklenemedi');
      }

      // Public URL'i al
      final imageUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print('Fotoğraf yükleme hatası: $e');
      throw Exception('Fotoğraf yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> deleteFortuneImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath =
          pathSegments.sublist(pathSegments.indexOf(_bucketName) + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      print('Fotoğraf silme hatası: $e');
      throw Exception('Fotoğraf silinirken bir hata oluştu: $e');
    }
  }
}