import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    DateTime? birthDate,
    String? zodiacSign,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Burç hesaplama yardımcı fonksiyonu
String calculateZodiacSign(DateTime birthDate) {
  int month = birthDate.month;
  int day = birthDate.day;

  switch (month) {
    case 1: // Ocak
      return day <= 19 ? 'oğlak' : 'kova';
    case 2: // Şubat
      return day <= 18 ? 'kova' : 'balık';
    case 3: // Mart
      return day <= 20 ? 'balık' : 'koç';
    case 4: // Nisan
      return day <= 19 ? 'koç' : 'boğa';
    case 5: // Mayıs
      return day <= 20 ? 'boğa' : 'ikizler';
    case 6: // Haziran
      return day <= 20 ? 'ikizler' : 'yengeç';
    case 7: // Temmuz
      return day <= 22 ? 'yengeç' : 'aslan';
    case 8: // Ağustos
      return day <= 22 ? 'aslan' : 'başak';
    case 9: // Eylül
      return day <= 22 ? 'başak' : 'terazi';
    case 10: // Ekim
      return day <= 22 ? 'terazi' : 'akrep';
    case 11: // Kasım
      return day <= 21 ? 'akrep' : 'yay';
    case 12: // Aralık
      return day <= 21 ? 'yay' : 'oğlak';
    default:
      throw Exception('Geçersiz ay');
  }
}
