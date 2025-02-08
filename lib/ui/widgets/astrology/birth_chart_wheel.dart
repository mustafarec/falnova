import 'dart:math';
import 'package:flutter/material.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

class BirthChartWheel extends StatefulWidget {
  final BirthChart birthChart;

  const BirthChartWheel({
    super.key,
    required this.birthChart,
  });

  @override
  State<BirthChartWheel> createState() => _BirthChartWheelState();
}

class _BirthChartWheelState extends State<BirthChartWheel> {
  String? selectedPlanet;
  Offset? tapPosition;

  int _getSignStartDegree(String sign) {
    final signs = [
      'Koç',
      'Boğa',
      'İkizler',
      'Yengeç',
      'Aslan',
      'Başak',
      'Terazi',
      'Akrep',
      'Yay',
      'Oğlak',
      'Kova',
      'Balık'
    ];
    return signs.indexOf(sign) * 30;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      tapPosition = details.localPosition;
      selectedPlanet = _findTappedPlanet(tapPosition!);
    });
  }

  String? _findTappedPlanet(Offset position) {
    final size = context.size!;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.7;
    final distance = innerRadius * 0.8;

    for (final entry in widget.birthChart.planets.entries) {
      final planetPos = entry.value;
      final angle =
          (-planetPos.degree - _getSignStartDegree(planetPos.sign) - 90) *
              pi /
              180;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);

      final planetCenter = Offset(x, y);
      if ((position - planetCenter).distance < 15) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _BirthChartPainter(
                birthChart: widget.birthChart,
                selectedPlanet: selectedPlanet,
              ),
            ),
          ),
          if (selectedPlanet != null && tapPosition != null)
            Positioned(
              left: tapPosition!.dx,
              top: tapPosition!.dy,
              child: _PlanetInfoCard(
                planet: selectedPlanet!,
                position: widget.birthChart.planets[selectedPlanet]!,
                onClose: () => setState(() => selectedPlanet = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanetInfoCard extends StatelessWidget {
  final String planet;
  final PlanetPosition position;
  final VoidCallback onClose;

  const _PlanetInfoCard({
    required this.planet,
    required this.position,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  planet,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Text('Burç: ${position.sign}'),
            Text('Derece: ${position.degree.toStringAsFixed(2)}°'),
            Text('Ev: ${position.house}'),
            if (position.isRetrograde)
              const Text(
                'Retro',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class _BirthChartPainter extends CustomPainter {
  final BirthChart birthChart;
  final String? selectedPlanet;

  _BirthChartPainter({required this.birthChart, this.selectedPlanet});

  int _getSignStartDegree(String sign) {
    final signs = [
      'Koç',
      'Boğa',
      'İkizler',
      'Yengeç',
      'Aslan',
      'Başak',
      'Terazi',
      'Akrep',
      'Yay',
      'Oğlak',
      'Kova',
      'Balık'
    ];
    return signs.indexOf(sign) * 30;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final middleRadius = outerRadius * 0.85;
    final innerRadius = outerRadius * 0.7;

    // Arka plan
    final bgPaint = Paint()
      ..color = const Color(0xFFFAF8FF) // Çok açık mor arka plan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, bgPaint);

    // Ana stiller
    final mainPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Dış çemberler
    canvas.drawCircle(center, outerRadius, mainPaint);
    canvas.drawCircle(center, middleRadius, mainPaint);
    canvas.drawCircle(center, innerRadius, mainPaint);

    // Derece çizgileri
    for (int i = 0; i < 360; i++) {
      if (i % 5 == 0) {
        final angle = -i * pi / 180;
        final isMainDegree = i % 30 == 0;
        final lineLength = isMainDegree ? 10.0 : 5.0;

        canvas.drawLine(
          Offset(
            center.dx + outerRadius * cos(angle),
            center.dy + outerRadius * sin(angle),
          ),
          Offset(
            center.dx + (outerRadius - lineLength) * cos(angle),
            center.dy + (outerRadius - lineLength) * sin(angle),
          ),
          mainPaint..strokeWidth = isMainDegree ? 0.8 : 0.4,
        );
      }
    }

    // Burç bölümleri
    for (int i = 0; i < 12; i++) {
      final startAngle = -i * 30 * pi / 180;

      // Ana burç çizgisi
      canvas.drawLine(
        Offset(
          center.dx + outerRadius * cos(startAngle),
          center.dy + outerRadius * sin(startAngle),
        ),
        Offset(
          center.dx + middleRadius * cos(startAngle),
          center.dy + middleRadius * sin(startAngle),
        ),
        mainPaint..strokeWidth = 0.8,
      );

      // Burç sembolleri
      final symbolAngle = -(i * 30 + 15) * pi / 180;
      final symbolRadius = (outerRadius + middleRadius) / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getZodiacSymbol(i),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + symbolRadius * cos(symbolAngle) - textPainter.width / 2,
          center.dy + symbolRadius * sin(symbolAngle) - textPainter.height / 2,
        ),
      );
    }

    // Ev çizgileri ve numaraları
    for (int i = 0; i < 12; i++) {
      final startAngle = -i * 30 * pi / 180;

      // Ev çizgisi
      canvas.drawLine(
        Offset(
          center.dx + middleRadius * cos(startAngle),
          center.dy + middleRadius * sin(startAngle),
        ),
        Offset(
          center.dx + innerRadius * cos(startAngle),
          center.dy + innerRadius * sin(startAngle),
        ),
        mainPaint..strokeWidth = 0.8,
      );

      // Ev numarası
      final numberAngle = -(i * 30 + 15) * pi / 180;
      final numberRadius = (middleRadius + innerRadius) / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + numberRadius * cos(numberAngle) - textPainter.width / 2,
          center.dy + numberRadius * sin(numberAngle) - textPainter.height / 2,
        ),
      );
    }

    // Açılar
    birthChart.aspects.forEach((planetName, aspects) {
      for (final aspect in aspects) {
        final planet1Pos = birthChart.planets[aspect.planet1]!;
        final planet2Pos = birthChart.planets[aspect.planet2]!;

        final angle1 =
            (-planet1Pos.degree - _getSignStartDegree(planet1Pos.sign) - 90) *
                pi /
                180;
        final angle2 =
            (-planet2Pos.degree - _getSignStartDegree(planet2Pos.sign) - 90) *
                pi /
                180;

        final x1 = center.dx + innerRadius * 0.8 * cos(angle1);
        final y1 = center.dy + innerRadius * 0.8 * sin(angle1);
        final x2 = center.dx + innerRadius * 0.8 * cos(angle2);
        final y2 = center.dy + innerRadius * 0.8 * sin(angle2);

        final aspectPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        switch (aspect.aspectType.toLowerCase()) {
          case 'conjunction':
            aspectPaint.color = Colors.purple.withOpacity(0.5);
            break;
          case 'opposition':
            aspectPaint.color = Colors.red.withOpacity(0.5);
            break;
          case 'trine':
            aspectPaint.color = Colors.blue.withOpacity(0.5);
            break;
          case 'square':
            aspectPaint.color = Colors.red.withOpacity(0.5);
            break;
          case 'sextile':
            aspectPaint.color = Colors.green.withOpacity(0.5);
            break;
          default:
            aspectPaint.color = Colors.grey.withOpacity(0.5);
        }

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), aspectPaint);
      }
    });

    // Gezegen sembolleri
    birthChart.planets.forEach((name, position) {
      final angle =
          (-position.degree - _getSignStartDegree(position.sign) - 90) *
              pi /
              180;
      final distance = innerRadius * 0.8;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);

      // Beyaz arka plan dairesi
      final bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 10, bgPaint);

      // Gezegen sembolü
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getPlanetSymbol(name),
          style: TextStyle(
            fontSize: 16,
            color: _getPlanetColor(name),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    });
  }

  Color _getPlanetColor(String planet) {
    switch (planet) {
      case 'Güneş':
        return Colors.orange;
      case 'Ay':
        return Colors.blue;
      case 'Merkür':
        return Colors.purple;
      case 'Venüs':
        return Colors.pink;
      case 'Mars':
        return Colors.red;
      case 'Jüpiter':
        return Colors.indigo;
      case 'Satürn':
        return Colors.brown;
      case 'Uranüs':
        return Colors.teal;
      case 'Neptün':
        return Colors.blue;
      case 'Plüton':
        return Colors.deepPurple;
      default:
        return Colors.black87;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  String _getPlanetSymbol(String planet) {
    const symbols = {
      'Güneş': '☉',
      'Ay': '☽',
      'Merkür': '☿',
      'Venüs': '♀',
      'Mars': '♂',
      'Jüpiter': '♃',
      'Satürn': '♄',
      'Uranüs': '♅',
      'Neptün': '♆',
      'Plüton': '♇',
    };
    return symbols[planet] ?? '?';
  }

  String _getZodiacSymbol(int index) {
    const symbols = [
      '♈',
      '♉',
      '♊',
      '♋',
      '♌',
      '♍',
      '♎',
      '♏',
      '♐',
      '♑',
      '♒',
      '♓'
    ];
    return symbols[index];
  }
}
