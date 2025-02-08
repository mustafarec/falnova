import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'house_interpretation_service.g.dart';

@riverpod
class HouseInterpretationService extends _$HouseInterpretationService {
  @override
  Future<Map<String, String>> build() async {
    return {};
  }

  String getHouseInterpretation(
      int houseNumber, String sign, List<String> planets) {
    final baseInterpretation = _getBaseHouseInterpretation(houseNumber);
    final signInfluence = _getSignInfluence(sign, houseNumber);
    final planetaryInfluence = _getPlanetaryInfluence(planets, houseNumber);

    return '''
$baseInterpretation

${sign.isNotEmpty ? 'Burç Etkisi:\n$signInfluence' : ''}

${planets.isNotEmpty ? 'Gezegen Etkileri:\n$planetaryInfluence' : ''}

${_getHouseAdvice(houseNumber, sign, planets)}
''';
  }

  String _getHouseAdvice(int houseNumber, String sign, List<String> planets) {
    String advice = '\nTavsiyeler:\n';

    // Temel ev tavsiyeleri
    switch (houseNumber) {
      case 1:
        advice += '- Kişisel tarzınızı ve imajınızı geliştirin\n';
        advice += '- Kendinizi daha iyi ifade etmenin yollarını arayın\n';
        if (sign == 'Koç' || sign == 'Aslan' || sign == 'Yay') {
          advice += '- Liderlik özelliklerinizi ön plana çıkarın\n';
          advice += '- Yeni girişimlerde bulunmaktan çekinmeyin\n';
        } else if (sign == 'Boğa' || sign == 'Başak' || sign == 'Oğlak') {
          advice += '- Pratik ve gerçekçi yaklaşımlarınızı koruyun\n';
          advice += '- Kararlı adımlarla ilerleyin\n';
        } else if (sign == 'İkizler' || sign == 'Terazi' || sign == 'Kova') {
          advice += '- Sosyal becerilerinizi geliştirin\n';
          advice += '- Yeni fikirler ve yaklaşımlar deneyin\n';
        }
        break;

      case 2:
        advice += '- Finansal planlarınızı gözden geçirin\n';
        advice += '- Değerlerinizi ve önceliklerinizi belirleyin\n';
        if (planets.contains('Venüs')) {
          advice += '- Finansal fırsatları değerlendirin\n';
          advice += '- Yatırım konularında şanslı bir dönemdesiniz\n';
        }
        if (planets.contains('Jüpiter')) {
          advice += '- Maddi konularda genişleme fırsatları var\n';
        }
        break;

      case 3:
        advice += '- İletişim becerilerinizi geliştirin\n';
        advice += '- Yakın çevrenizle bağlarınızı güçlendirin\n';
        if (planets.contains('Merkür')) {
          advice += '- Yeni öğrenme fırsatlarını değerlendirin\n';
          advice += '- Yazma ve konuşma yeteneklerinizi kullanın\n';
        }
        break;

      case 4:
        advice += '- Aile ilişkilerinize özen gösterin\n';
        advice += '- Ev yaşamınızı düzenleyin\n';
        if (planets.contains('Ay')) {
          advice += '- Duygusal ihtiyaçlarınıza önem verin\n';
          advice += '- Ailenizle kaliteli zaman geçirin\n';
        }
        break;

      case 5:
        advice += '- Yaratıcı potansiyelinizi keşfedin\n';
        advice += '- Hobiler ve eğlenceli aktiviteler için zaman ayırın\n';
        if (planets.contains('Güneş')) {
          advice += '- Kendinizi sanatsal açıdan ifade edin\n';
          advice += '- Romantik ilişkilerinize özen gösterin\n';
        }
        break;

      case 6:
        advice += '- Günlük rutinlerinizi düzenleyin\n';
        advice += '- Sağlık alışkanlıklarınızı gözden geçirin\n';
        if (planets.contains('Mars')) {
          advice += '- İş hayatınızda daha aktif olun\n';
          advice += '- Fiziksel aktivitelere yönelin\n';
        }
        break;

      case 7:
        advice += '- İlişkilerinizi dengeli bir şekilde yürütün\n';
        advice += '- Ortaklıklarda açık iletişimi koruyun\n';
        if (planets.contains('Venüs')) {
          advice += '- Yeni ilişkiler için uygun bir dönem\n';
          advice += '- Mevcut ilişkilerinizi güçlendirin\n';
        }
        break;

      case 8:
        advice += '- Finansal ortaklıkları dikkatle değerlendirin\n';
        advice += '- İç dünyanızı keşfedin\n';
        if (planets.contains('Plüton')) {
          advice += '- Dönüşüm fırsatlarını değerlendirin\n';
          advice += '- Derin araştırmalar yapın\n';
        }
        break;

      case 9:
        advice += '- Yeni öğrenme fırsatlarını değerlendirin\n';
        advice += '- Farklı kültürleri tanıyın\n';
        if (planets.contains('Jüpiter')) {
          advice += '- Uzak yolculuklar planlayın\n';
          advice += '- Manevi gelişiminize önem verin\n';
        }
        break;

      case 10:
        advice += '- Kariyer hedeflerinizi netleştirin\n';
        advice += '- Profesyonel imajınızı güçlendirin\n';
        if (planets.contains('Satürn')) {
          advice += '- Uzun vadeli planlar yapın\n';
          advice += '- Sorumluluk almaktan çekinmeyin\n';
        }
        break;

      case 11:
        advice += '- Sosyal çevrenizi genişletin\n';
        advice += '- Grup aktivitelerine katılın\n';
        if (planets.contains('Uranüs')) {
          advice += '- Yenilikçi projelere dahil olun\n';
          advice += '- Teknolojik gelişmeleri takip edin\n';
        }
        break;

      case 12:
        advice += '- İçsel huzurunuzu bulun\n';
        advice += '- Manevi çalışmalara zaman ayırın\n';
        if (planets.contains('Neptün')) {
          advice += '- Meditasyon ve yoga gibi aktivitelere yönelin\n';
          advice += '- Sanatsal yeteneklerinizi geliştirin\n';
        }
        break;
    }

    return advice;
  }

  String _getPlanetaryInfluence(List<String> planets, int houseNumber) {
    if (planets.isEmpty) return '';

    final interpretations = planets
        .map((planet) {
          final baseInterpretation = switch (planet) {
            'Güneş' =>
              '- Güneş: Kimliğinizi ve yaşam enerjinizi bu ev konularında gösterirsiniz.',
            'Ay' =>
              '- Ay: Duygusal ihtiyaçlarınız ve içgüdüsel tepkileriniz bu ev konularında ortaya çıkar.',
            'Merkür' =>
              '- Merkür: İletişim ve düşünce biçiminiz bu ev konularında belirginleşir.',
            'Venüs' =>
              '- Venüs: Sevgi, güzellik ve değer anlayışınız bu ev konularında kendini gösterir.',
            'Mars' =>
              '- Mars: Enerji ve inisiyatif kullanımınız bu ev konularında yoğunlaşır.',
            'Jüpiter' =>
              '- Jüpiter: Büyüme ve genişleme fırsatlarınız bu ev konularında ortaya çıkar.',
            'Satürn' =>
              '- Satürn: Sorumluluk ve sınırlamalarınız bu ev konularında belirginleşir.',
            'Uranüs' =>
              '- Uranüs: Değişim ve yenilik arayışınız bu ev konularında kendini gösterir.',
            'Neptün' =>
              '- Neptün: İdeal ve hayalleriniz bu ev konularında yoğunlaşır.',
            'Plüton' =>
              '- Plüton: Dönüşüm ve güç dinamikleriniz bu ev konularında ortaya çıkar.',
            _ => '',
          };

          // Eve özel gezegen yorumları
          final houseSpecific =
              _getHouseSpecificPlanetaryInfluence(planet, houseNumber);

          return '$baseInterpretation\n$houseSpecific';
        })
        .where((interpretation) => interpretation.isNotEmpty)
        .toList();

    return interpretations.join('\n');
  }

  String _getHouseSpecificPlanetaryInfluence(String planet, int houseNumber) {
    // Eve özel gezegen yorumları
    switch (houseNumber) {
      case 1 when planet == 'Mars':
        return '  Bu evdeki Mars, güçlü bir kişisel inisiyatif ve liderlik yeteneği sağlar.';
      case 2 when planet == 'Venüs':
        return '  Bu evdeki Venüs, finansal konularda şans ve estetik değer anlayışı getirir.';
      case 3 when planet == 'Merkür':
        return '  Bu evdeki Merkür, güçlü iletişim becerileri ve entelektüel merak sağlar.';
      case 4 when planet == 'Ay':
        return '  Bu evdeki Ay, güçlü aile bağları ve duygusal güvenlik ihtiyacı gösterir.';
      case 5 when planet == 'Güneş':
        return '  Bu evdeki Güneş, yaratıcı kendini ifade ve güçlü liderlik özellikleri sağlar.';
      default:
        return '';
    }
  }

  String _getBaseHouseInterpretation(int houseNumber) {
    switch (houseNumber) {
      case 1:
        return '1. Ev (Yükselen): Kişisel imajınız, fiziksel görünümünüz ve kendinizi dünyaya sunuş biçiminiz. Bu ev, kişiliğinizin dışa dönük yönlerini ve ilk izlenimleri temsil eder.';
      case 2:
        return '2. Ev: Maddi kaynaklar, değerler ve öz-değer duygunuz. Bu ev, finansal konular, sahip olduklarınız ve kazanç potansiyelinizi gösterir.';
      case 3:
        return '3. Ev: İletişim, öğrenme ve yakın çevre. Kardeşler, kısa yolculuklar ve günlük iletişim biçimleriniz bu evin konularıdır.';
      case 4:
        return '4. Ev (IC): Ev, aile ve kökler. Duygusal temelleriniz, aileniz ve geçmişinizle ilgili konuları temsil eder.';
      case 5:
        return '5. Ev: Yaratıcılık, romantik ilişkiler ve kendini ifade. Hobiler, çocuklar ve eğlence bu evin kapsamındadır.';
      case 6:
        return '6. Ev: Günlük rutinler, sağlık ve hizmet. İş hayatınız, sağlık alışkanlıklarınız ve düzen ihtiyacınızı gösterir.';
      case 7:
        return '7. Ev (Descendant): İlişkiler ve ortaklıklar. Evlilik, iş ortaklıkları ve yakın ilişkilerinizi temsil eder.';
      case 8:
        return '8. Ev: Dönüşüm, paylaşılan kaynaklar ve derin psikolojik konular. Miras, vergi ve ortak finansal konuları kapsar.';
      case 9:
        return '9. Ev: Yüksek öğrenim, uzak yolculuklar ve felsefe. Manevi inançlar ve kültürel deneyimler bu evin konularıdır.';
      case 10:
        return '10. Ev (MC): Kariyer, toplumsal statü ve hedefler. Başarılarınız ve toplumsal imajınızı temsil eder.';
      case 11:
        return '11. Ev: Arkadaşlıklar, gruplar ve gelecek hedefleri. Sosyal çevre ve ideallerinizi gösterir.';
      case 12:
        return '12. Ev: Bilinçaltı, maneviyat ve gizli konular. Ruhsal gelişim ve içsel yolculuğunuzu temsil eder.';
      default:
        return '';
    }
  }

  String _getSignInfluence(String sign, int houseNumber) {
    // Burç etkilerini ev numarasına göre özelleştir
    switch (sign) {
      case 'Koç':
        return 'Bu evde Koç burcu enerjisi, inisiyatif alma, liderlik ve cesaret getiriyor. Yeni başlangıçlar için güçlü bir dürtü sağlıyor.';
      case 'Boğa':
        return 'Boğa burcu bu eve istikrar, güvenilirlik ve pratiklik katıyor. Maddi güvenlik ve konfor önem kazanıyor.';
      case 'İkizler':
        return 'İkizler burcu bu eve iletişim becerisi, esneklik ve merak katıyor. Bilgi alışverişi ve sosyal etkileşim öne çıkıyor.';
      case 'Yengeç':
        return 'Yengeç burcu bu eve duygusal derinlik, koruyuculuk ve sezgisellik getiriyor. Aile ve güvenlik konuları önem kazanıyor.';
      case 'Aslan':
        return 'Aslan burcu bu eve yaratıcılık, özgüven ve liderlik katıyor. Kendini ifade etme ve tanınma ihtiyacı öne çıkıyor.';
      case 'Başak':
        return 'Başak burcu bu eve analitik düşünce, düzen ve hizmet etme arzusu getiriyor. Detaylar ve verimlilik önem kazanıyor.';
      case 'Terazi':
        return 'Terazi burcu bu eve denge, uyum ve adalet duygusu katıyor. İlişkiler ve işbirliği öne çıkıyor.';
      case 'Akrep':
        return 'Akrep burcu bu eve derinlik, yoğunluk ve dönüşüm gücü getiriyor. Gizli konular ve psikolojik içgörü önem kazanıyor.';
      case 'Yay':
        return 'Yay burcu bu eve genişleme, optimizm ve macera ruhu katıyor. Öğrenme ve keşif arzusu öne çıkıyor.';
      case 'Oğlak':
        return 'Oğlak burcu bu eve disiplin, sorumluluk ve yapı getiriyor. Hedefler ve başarı odağı önem kazanıyor.';
      case 'Kova':
        return 'Kova burcu bu eve yenilikçilik, özgünlük ve insancıllık katıyor. Sosyal farkındalık ve değişim öne çıkıyor.';
      case 'Balık':
        return 'Balık burcu bu eve sezgisellik, merhamet ve maneviyat getiriyor. Ruhsal konular ve empati önem kazanıyor.';
      default:
        return '';
    }
  }
}
