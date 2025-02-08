import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

part 'aspect_pattern_service.g.dart';

@riverpod
class AspectPatternService extends _$AspectPatternService {
  @override
  Future<Map<String, String>> build() async {
    return {};
  }

  List<AspectPattern> findAspectPatterns(BirthChart birthChart) {
    final patterns = <AspectPattern>[];

    // Grand Trine (Büyük Üçgen)
    patterns.addAll(_findGrandTrines(birthChart));

    // T-Square (T-Kare)
    patterns.addAll(_findTSquares(birthChart));

    // Grand Cross (Büyük Kare)
    patterns.addAll(_findGrandCrosses(birthChart));

    // Yod (Tanrının Parmağı)
    patterns.addAll(_findYods(birthChart));

    // Mystic Rectangle (Mistik Dikdörtgen)
    patterns.addAll(_findMysticRectangles(birthChart));

    // Kite (Uçurtma)
    patterns.addAll(_findKites(birthChart));

    return patterns;
  }

  String getPatternInterpretation(AspectPattern pattern) {
    final baseInterpretation = _getBasePatternInterpretation(pattern.type);
    final planetaryInfluence = _getPlanetaryPatternInfluence(pattern);
    final advice = _getPatternAdvice(pattern);

    return '''
$baseInterpretation

Gezegen Etkileri:
$planetaryInfluence

Tavsiyeler:
$advice
''';
  }

  List<AspectPattern> _findGrandTrines(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // Üç gezegen arasında 120 derecelik açılar arayın
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'trine') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'trine' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // Üçüncü trini kontrol et
                  final thirdTrine = aspects[aspect2.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'trine' &&
                          a.planet2 == entry1.key) ??
                      false;

                  if (thirdTrine) {
                    patterns.add(AspectPattern(
                      type: 'Grand Trine',
                      planets: [entry1.key, aspect1.planet2, aspect2.planet2],
                      description:
                          'Üç gezegen arasında 120 derecelik açılarla oluşan harmonik bir kalıp.',
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }

  String _getBasePatternInterpretation(String patternType) {
    switch (patternType) {
      case 'Grand Trine':
        return 'Büyük Üçgen, doğal yetenekler ve kolayca akan enerjileri temsil eder. Bu kalıp, yaşamınızda doğal bir uyum ve akış sağlar.';
      case 'T-Square':
        return 'T-Kare, dinamik enerji ve değişim potansiyelini gösterir. Bu kalıp, kişisel gelişim için motivasyon ve zorluklar getirir.';
      case 'Grand Cross':
        return 'Büyük Kare, dört yönlü gerilim ve denge ihtiyacını gösterir. Bu kalıp, güçlü bir dönüşüm potansiyeli taşır.';
      case 'Yod':
        return 'Tanrının Parmağı olarak da bilinen Yod, özel bir misyon ve kader yolunu işaret eder. Bu kalıp, ruhsal gelişim fırsatları sunar.';
      case 'Mystic Rectangle':
        return 'Mistik Dikdörtgen, pratik yetenekler ve ruhsal içgörülerin dengesini temsil eder. Bu kalıp, maddi ve manevi dengeyi sağlar.';
      case 'Kite':
        return 'Uçurtma, Büyük Üçgenin sağladığı yetenekleri pratik bir şekilde kullanma fırsatı sunar. Bu kalıp, potansiyeli gerçeğe dönüştürür.';
      default:
        return '';
    }
  }

  String _getPlanetaryPatternInfluence(AspectPattern pattern) {
    String influence = '';

    for (final planet in pattern.planets) {
      influence += '- $planet: ';
      switch (planet) {
        case 'Güneş':
          influence += 'Kişilik ve yaratıcı ifade\n';
        case 'Ay':
          influence += 'Duygusal tepkiler ve içgüdüler\n';
        case 'Merkür':
          influence += 'Düşünce ve iletişim tarzı\n';
        case 'Venüs':
          influence += 'Değerler ve ilişki yaklaşımı\n';
        case 'Mars':
          influence += 'Motivasyon ve enerji kullanımı\n';
        case 'Jüpiter':
          influence += 'Büyüme ve genişleme alanları\n';
        case 'Satürn':
          influence += 'Sorumluluk ve sınırlar\n';
        case 'Uranüs':
          influence += 'Yenilik ve değişim alanları\n';
        case 'Neptün':
          influence += 'Ruhsal ve sanatsal eğilimler\n';
        case 'Plüton':
          influence += 'Dönüşüm ve güç dinamikleri\n';
      }
    }

    return influence;
  }

  String _getPatternAdvice(AspectPattern pattern) {
    switch (pattern.type) {
      case 'Grand Trine':
        return '''
- Doğal yeteneklerinizi aktif olarak kullanın
- Akışa karşı direnmeyin, fırsatları değerlendirin
- Rahatlık bölgenizden çıkmaya çalışın''';
      case 'T-Square':
        return '''
- Zorluklardan öğrenmeye odaklanın
- Enerjiyi yapıcı projelere yönlendirin
- Denge noktası bulmaya çalışın''';
      case 'Grand Cross':
        return '''
- İç çatışmaları yapıcı eyleme dönüştürün
- Dört alanı dengeli bir şekilde geliştirin
- Değişime açık olun''';
      case 'Yod':
        return '''
- Sezgilerinizi dinleyin
- Yaşam amacınızı keşfedin
- Uyum sağlama yeteneğinizi geliştirin''';
      case 'Mystic Rectangle':
        return '''
- Pratik ve ruhsal dengeyi koruyun
- Yeteneklerinizi somut projelerde kullanın
- İç görülerinizi günlük hayata uygulayın''';
      case 'Kite':
        return '''
- Fırsatları değerlendirin
- Yeteneklerinizi pratik sonuçlar için kullanın
- Başkalarına ilham verin''';
      default:
        return '';
    }
  }

  List<AspectPattern> _findTSquares(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // T-Square: İki gezegen arasında kare (90°), bir gezegen ile diğer ikisi arasında karşıt (180°) açı
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'square') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'square' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // Karşıt açıyı kontrol et
                  final opposition = aspects[aspect1.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'opposition' &&
                          a.planet2 == aspect2.planet2) ??
                      false;

                  if (opposition) {
                    patterns.add(AspectPattern(
                      type: 'T-Square',
                      planets: [entry1.key, aspect1.planet2, aspect2.planet2],
                      description:
                          'İki kare (90°) ve bir karşıt (180°) açıdan oluşan dinamik bir kalıp.',
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }

  List<AspectPattern> _findGrandCrosses(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // Grand Cross: Dört gezegen arasında kare (90°) ve karşıt (180°) açılar
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'square') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'square' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // Üçüncü kareyi kontrol et
                  final thirdSquare = aspects[aspect2.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'square' &&
                          a.planet2 != entry1.key &&
                          a.planet2 != aspect1.planet2) ??
                      false;

                  if (thirdSquare) {
                    // Dördüncü kareyi ve karşıt açıları kontrol et
                    final fourthSquare = aspects[entry1.key]?.any((a) =>
                            a.aspectType.toLowerCase() == 'square' &&
                            a.planet2 == aspect2.planet2) ??
                        false;

                    final oppositions = [
                      aspects[entry1.key]?.any((a) =>
                              a.aspectType.toLowerCase() == 'opposition' &&
                              a.planet2 == aspect2.planet2) ??
                          false,
                      aspects[aspect1.planet2]?.any((a) =>
                              a.aspectType.toLowerCase() == 'opposition' &&
                              a.planet2 == entry2.key) ??
                          false,
                    ];

                    if (fourthSquare && oppositions.every((op) => op)) {
                      patterns.add(AspectPattern(
                        type: 'Grand Cross',
                        planets: [
                          entry1.key,
                          aspect1.planet2,
                          aspect2.planet2,
                          entry2.key
                        ],
                        description:
                            'Dört gezegen arasında kare (90°) ve karşıt (180°) açılardan oluşan güçlü bir kalıp.',
                      ));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }

  List<AspectPattern> _findYods(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // Yod: İki gezegen arasında altmışlık (60°), her iki gezegen ile üçüncü gezegen arasında yüzellilik (150°) açı
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'sextile') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'quincunx' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // İkinci yüzelliliği kontrol et
                  final secondQuincunx = aspects[aspect1.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'quincunx' &&
                          a.planet2 == aspect2.planet2) ??
                      false;

                  if (secondQuincunx) {
                    patterns.add(AspectPattern(
                      type: 'Yod',
                      planets: [entry1.key, aspect1.planet2, aspect2.planet2],
                      description:
                          'Bir altmışlık (60°) ve iki yüzellilik (150°) açıdan oluşan, özel bir misyonu işaret eden kalıp.',
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }

  List<AspectPattern> _findMysticRectangles(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // Mystic Rectangle: İki çift karşıt (180°) açı ve bunları bağlayan altmışlık (60°) ve üçgen (120°) açılar
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'opposition') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'opposition' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // Sextile ve trine açıları kontrol et
                  final sextile1 = aspects[entry1.key]?.any((a) =>
                          a.aspectType.toLowerCase() == 'sextile' &&
                          a.planet2 == entry2.key) ??
                      false;
                  final sextile2 = aspects[aspect1.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'sextile' &&
                          a.planet2 == aspect2.planet2) ??
                      false;
                  final trine1 = aspects[entry1.key]?.any((a) =>
                          a.aspectType.toLowerCase() == 'trine' &&
                          a.planet2 == aspect2.planet2) ??
                      false;
                  final trine2 = aspects[aspect1.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'trine' &&
                          a.planet2 == entry2.key) ??
                      false;

                  if (sextile1 && sextile2 && trine1 && trine2) {
                    patterns.add(AspectPattern(
                      type: 'Mystic Rectangle',
                      planets: [
                        entry1.key,
                        aspect1.planet2,
                        entry2.key,
                        aspect2.planet2
                      ],
                      description:
                          'İki karşıt (180°), iki altmışlık (60°) ve iki üçgen (120°) açıdan oluşan harmonik bir kalıp.',
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }

  List<AspectPattern> _findKites(BirthChart birthChart) {
    final patterns = <AspectPattern>[];
    final aspects = birthChart.aspects;

    // Kite: Büyük Üçgen (Grand Trine) ve bir karşıt (180°) açı
    for (final entry1 in aspects.entries) {
      for (final aspect1 in entry1.value) {
        if (aspect1.aspectType.toLowerCase() == 'trine') {
          for (final entry2 in aspects.entries) {
            if (entry2.key != entry1.key && entry2.key != aspect1.planet2) {
              for (final aspect2 in entry2.value) {
                if (aspect2.aspectType.toLowerCase() == 'trine' &&
                    aspect2.planet2 != entry1.key &&
                    aspect2.planet2 != aspect1.planet2) {
                  // Üçüncü trini kontrol et
                  final thirdTrine = aspects[aspect2.planet2]?.any((a) =>
                          a.aspectType.toLowerCase() == 'trine' &&
                          a.planet2 == entry1.key) ??
                      false;

                  if (thirdTrine) {
                    // Karşıt açıyı kontrol et
                    final opposition = aspects[entry1.key]?.any((a) =>
                            a.aspectType.toLowerCase() == 'opposition' &&
                            a.planet2 == aspect2.planet2) ??
                        false;

                    if (opposition) {
                      patterns.add(AspectPattern(
                        type: 'Kite',
                        planets: [
                          entry1.key,
                          aspect1.planet2,
                          aspect2.planet2,
                          entry2.key
                        ],
                        description:
                            'Büyük Üçgen (Grand Trine) ve bir karşıt (180°) açıdan oluşan, potansiyeli gerçeğe dönüştüren kalıp.',
                      ));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return patterns;
  }
}

class AspectPattern {
  final String type;
  final List<String> planets;
  final String description;

  AspectPattern({
    required this.type,
    required this.planets,
    required this.description,
  });
}
