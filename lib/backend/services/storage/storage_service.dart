import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final _supabase = Supabase.instance.client;
  final _bucketName = 'images';
  final _logger = Logger();

  Future<String> uploadFortuneImage(String imagePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      final file = File(imagePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
      final filePath = '$userId/fortune-readings/$fileName';

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

      // Private URL'i al
      final imageUrl = _supabase.storage
          .from(_bucketName)
          .createSignedUrl(filePath, 3600); // 1 saatlik geçerli URL

      return imageUrl;
    } catch (e) {
      _logger.e('Fotoğraf yükleme hatası: $e');
      throw Exception('Fotoğraf yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> deleteFortuneImage(String imageUrl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath =
          pathSegments.sublist(pathSegments.indexOf(_bucketName) + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      _logger.e('Fotoğraf silme hatası: $e');
      throw Exception('Fotoğraf silinirken bir hata oluştu: $e');
    }
  }

  Future<String> uploadPalmImage(String imagePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/palm-readings/$fileName';
      final bytes = await file.readAsBytes();

      await _supabase.storage.from(_bucketName).uploadBinary(filePath, bytes);

      // Private URL'i al
      final imageUrl = _supabase.storage
          .from(_bucketName)
          .createSignedUrl(filePath, 3600); // 1 saatlik geçerli URL

      return imageUrl;
    } catch (e) {
      _logger.e('El falı fotoğrafı yükleme hatası: $e');
      throw Exception('El falı fotoğrafı yüklenirken bir hata oluştu: $e');
    }
  }
}
