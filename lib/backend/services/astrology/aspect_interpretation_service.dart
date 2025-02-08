import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'aspect_interpretation_service.g.dart';

@riverpod
class AspectInterpretationService extends _$AspectInterpretationService {
  @override
  Future<Map<String, String>> build() async {
    return {};
  }

  String getAspectInterpretation(
      String planet1, String planet2, String aspectType) {
    final baseInterpretation = _getBaseAspectInterpretation(aspectType);
    final planetaryInfluence =
        _getPlanetaryAspectInfluence(planet1, planet2, aspectType);
    final advice = _getAspectAdvice(planet1, planet2, aspectType);

    return '''
$baseInterpretation

Gezegen Etkileşimi:
$planetaryInfluence

Tavsiyeler:
$advice
''';
  }

  String _getBaseAspectInterpretation(String aspectType) {
    switch (aspectType.toLowerCase()) {
      case 'conjunction':
        return 'Kavuşum (Conjunction) açısı, iki gezegenin enerjilerinin birleştiği ve yoğunlaştığı bir durumdur. Bu açı, yeni başlangıçları ve güçlü etkileri temsil eder.';
      case 'opposition':
        return 'Karşıt (Opposition) açı, iki gezegenin karşılıklı etkileşimini ve dengeleme ihtiyacını gösterir. Bu açı, farkındalık ve ilişkilerdeki gerilimleri temsil eder.';
      case 'trine':
        return 'Üçgen (Trine) açı, uyumlu ve destekleyici bir enerji akışını gösterir. Bu açı, doğal yetenekleri ve fırsatları temsil eder.';
      case 'square':
        return 'Kare (Square) açı, zorlayıcı ve geliştirici etkileri gösterir. Bu açı, değişim için gereken motivasyonu ve engelleri temsil eder.';
      case 'sextile':
        return 'Altmışlık (Sextile) açı, fırsatları ve potansiyel gelişim alanlarını gösterir. Bu açı, öğrenme ve işbirliği fırsatlarını temsil eder.';
      case 'semisextile':
        return 'Otuzluk (Semisextile) açı, hafif gerilimleri ve uyum sağlama ihtiyacını gösterir. Bu açı, küçük ayarlamalar ve adaptasyonu temsil eder.';
      case 'quincunx':
        return 'Yüzellilik (Quincunx) açı, uyumsuzluk ve ayarlama ihtiyacını gösterir. Bu açı, değişim ve adaptasyon gerektiren durumları temsil eder.';
      case 'semisquare':
        return 'Yarı Kare (Semisquare) açı, iç gerilim ve gelişim fırsatlarını gösterir. Bu açı, kişisel büyüme için gereken zorlukları temsil eder.';
      case 'sesquiquadrate':
        return 'Bir Buçuk Kare (Sesquiquadrate) açı, içsel ve dışsal çatışmaları gösterir. Bu açı, dönüşüm ve değişim için gereken baskıyı temsil eder.';
      default:
        return '';
    }
  }

  String _getPlanetaryAspectInfluence(
      String planet1, String planet2, String aspectType) {
    final isHarmonious =
        ['trine', 'sextile'].contains(aspectType.toLowerCase());
    final isChallenging =
        ['opposition', 'square'].contains(aspectType.toLowerCase());

    String influence = '';

    // Gezegen kombinasyonlarına göre yorumlar
    if (planet1 == 'Güneş' && planet2 == 'Ay') {
      influence = isHarmonious
          ? '- Duygusal ve mantıksal yönleriniz uyum içinde çalışır.'
          : isChallenging
              ? '- İç dünyanız ve dış görünüşünüz arasında denge kurma ihtiyacı.'
              : '- Kişiliğinizin farklı yönleri güçlü bir şekilde birleşir.';
    } else if (planet1 == 'Merkür' && planet2 == 'Venüs') {
      influence = isHarmonious
          ? '- İletişim ve sanatsal yetenekleriniz birbirini destekler.'
          : isChallenging
              ? '- Düşünceleriniz ve değerleriniz arasında uyum sağlama ihtiyacı.'
              : '- Zihinsel ve estetik yetenekleriniz bir arada çalışır.';
    }
    // Diğer gezegen kombinasyonları için benzer yapıda yorumlar eklenebilir

    return influence.isEmpty
        ? 'Bu gezegenler arasındaki etkileşim kişisel gelişiminiz için önemlidir.'
        : influence;
  }

  String _getAspectAdvice(String planet1, String planet2, String aspectType) {
    final isHarmonious =
        ['trine', 'sextile'].contains(aspectType.toLowerCase());
    final isChallenging =
        ['opposition', 'square'].contains(aspectType.toLowerCase());

    if (isHarmonious) {
      return '''
- Bu olumlu açının sağladığı fırsatları değerlendirin
- Doğal yeteneklerinizi geliştirmek için harekete geçin
- İşbirliği ve uyum için uygun bir dönem''';
    } else if (isChallenging) {
      return '''
- Zorluklardan öğrenmeye ve gelişmeye odaklanın
- Dengeli ve sabırlı bir yaklaşım benimseyin
- Değişim için gereken adımları planlayın''';
    } else {
      return '''
- Bu açının etkilerini gözlemleyin ve anlayın
- Kişisel gelişiminiz için bu enerjiyi kullanın
- Yeni başlangıçlar için fırsatları değerlendirin''';
    }
  }
}
