import 'package:flutter/material.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

class AspectTable extends StatelessWidget {
  final BirthChart birthChart;

  const AspectTable({
    super.key,
    required this.birthChart,
  });

  Color _getAspectColor(String aspectType) {
    switch (aspectType.toLowerCase()) {
      case 'conjunction':
        return Colors.purple;
      case 'opposition':
        return Colors.red;
      case 'trine':
        return Colors.blue;
      case 'square':
        return Colors.red;
      case 'sextile':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getAspectSymbol(String aspectType) {
    switch (aspectType.toLowerCase()) {
      case 'conjunction':
        return '☌';
      case 'opposition':
        return '☍';
      case 'trine':
        return '△';
      case 'square':
        return '□';
      case 'sextile':
        return '⚹';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final planets = birthChart.planets.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık satırı
            Row(
              children: [
                const SizedBox(width: 40), // Sol üst boş köşe
                ...planets.map((planet) => SizedBox(
                      width: 40,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          planet,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            // Açı tablosu
            ...List.generate(planets.length, (i) {
              return Row(
                children: [
                  // Satır başı gezegen
                  SizedBox(
                    width: 40,
                    child: Text(
                      planets[i],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Açı hücreleri
                  ...List.generate(planets.length, (j) {
                    if (j < i) {
                      // Alt üçgen bölgesi
                      final aspects = birthChart.aspects[planets[i]] ?? [];
                      final aspect = aspects.firstWhere(
                        (a) => a.planet2 == planets[j],
                        orElse: () => Aspect(
                          planet1: planets[i],
                          planet2: planets[j],
                          aspectType: '',
                          orb: 0,
                          isApplying: false,
                        ),
                      );

                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: aspect.aspectType.isEmpty
                              ? const Text('-')
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getAspectSymbol(aspect.aspectType),
                                      style: TextStyle(
                                        color:
                                            _getAspectColor(aspect.aspectType),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${aspect.orb.toStringAsFixed(1)}°',
                                      style: TextStyle(
                                        color:
                                            _getAspectColor(aspect.aspectType),
                                        fontSize: 10,
                                      ),
                                    ),
                                    Icon(
                                      aspect.isApplying
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 12,
                                      color: _getAspectColor(aspect.aspectType),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    } else {
                      // Üst üçgen bölgesi (boş)
                      return const SizedBox(width: 40, height: 40);
                    }
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
