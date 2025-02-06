import 'package:flutter/material.dart';
import 'package:falnova/backend/models/astrology/horoscope.dart';

class HoroscopeResultWidget extends StatelessWidget {
  final Horoscope horoscope;
  final ScrollController scrollController;

  const HoroscopeResultWidget({
    super.key,
    required this.horoscope,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '${horoscope.sign} Burcu',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                horoscope.dailyHoroscope,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildScoreCard(context),
              const SizedBox(height: 16),
              _buildLuckInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük Puanlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildScoreRow('Aşk', horoscope.scores['love'] ?? 0),
            _buildScoreRow('Kariyer', horoscope.scores['career'] ?? 0),
            _buildScoreRow('Para', horoscope.scores['money'] ?? 0),
            _buildScoreRow('Sağlık', horoscope.scores['health'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 10,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Şans Faktörleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (horoscope.luckNumber != null)
              _buildLuckRow('Şans Sayısı', horoscope.luckNumber!),
            if (horoscope.luckColor != null)
              _buildLuckRow('Şans Rengi', horoscope.luckColor!),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
