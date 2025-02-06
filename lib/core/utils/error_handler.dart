import 'package:logger/logger.dart';
import 'package:falnova/backend/services/ai/ai_service.dart';

class ErrorHandler {
  static final _logger = Logger();

  static String getUserFriendlyMessage(Exception error) {
    _logger.e('Hata oluştu', error: error);

    if (error is AiServiceException) {
      switch (error.code) {
        case 'API_ERROR':
          return 'Üzgünüz, şu anda hizmet kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
        case 'INTERPRETATION_ERROR':
          return 'Fal yorumlanırken bir sorun oluştu. Lütfen fincan fotoğrafını kontrol edip tekrar deneyin.';
        case 'HOROSCOPE_ERROR':
          return 'Burç yorumu alınamadı. Lütfen daha sonra tekrar deneyin.';
        default:
          return 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
      }
    }

    if (error.toString().contains('connection')) {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }

    return 'Bir sorun oluştu. Lütfen daha sonra tekrar deneyin.';
  }

  static void logError(String message, dynamic error,
      [StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
