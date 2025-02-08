import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:falnova/backend/services/astrology/horoscope_service.dart';
import 'package:logger/logger.dart';
import 'package:falnova/backend/models/astrology/horoscope.dart';
import 'package:falnova/ui/widgets/common/custom_app_bar.dart';
import 'package:falnova/backend/services/astrology/birth_chart_service.dart';
import 'package:falnova/backend/models/astrology/birth_chart.dart';

final _logger = Logger();
final _supabase = Supabase.instance.client;

String getZodiacSign(DateTime birthDate) {
  int month = birthDate.month;
  int day = birthDate.day;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Koç';
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Boğa';
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'İkizler';
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Yengeç';
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Aslan';
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Başak';
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Terazi';
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Akrep';
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Yay';
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Oğlak';
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Kova';
  return 'Balık';
}

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen>
    with AutomaticKeepAliveClientMixin {
  String? selectedSign;
  Horoscope? horoscope;
  bool isLoading = false;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserSign();
  }

  Future<void> _loadUserSign() async {
    if (selectedSign != null) return; // Eğer zaten yüklenmişse tekrar yükleme

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userData = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (userData['birth_date'] != null &&
            userData['birth_time'] != null &&
            userData['birth_city'] != null) {
          final birthDate = DateTime.parse(
              '${userData['birth_date']}\T${userData['birth_time']}');
          if (mounted) {
            setState(() {
              selectedSign = getZodiacSign(birthDate);
            });
            _loadHoroscope();
          }
        } else {
          if (mounted) {
            setState(() {
              selectedSign = 'Koç';
            });
            _loadHoroscope();
          }
        }
      }
    } catch (e) {
      _logger.e('Burç bilgisi alınamadı', error: e);
      if (mounted) {
        setState(() {
          selectedSign = 'Koç';
        });
        _loadHoroscope();
      }
    }
  }

  Future<void> _loadHoroscope() async {
    if (isLoading || selectedSign == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      BirthChart? birthChart;

      if (user != null) {
        // Kullanıcının doğum bilgilerini al
        final userData = await _supabase
            .from('profiles')
            .select('birth_date, birth_time, birth_city, latitude, longitude')
            .eq('id', user.id)
            .single();

        if (userData['birth_date'] != null &&
            userData['birth_time'] != null &&
            userData['birth_city'] != null) {
          // BirthChart servisini kullanarak doğum haritasını hesapla
          final birthChartService =
              ref.read(birthChartServiceProvider.notifier);
          birthChart = await birthChartService.calculateBirthChart(
            userId: user.id,
            birthDate: DateTime.parse(
                '${userData['birth_date']}\T${userData['birth_time']}'),
            birthPlace: userData['birth_city'],
            latitude: userData['latitude'] ?? 0.0,
            longitude: userData['longitude'] ?? 0.0,
          );
        }
      }

      final service = ref.read(horoscopeServiceProvider);
      final result = await service.getDailyHoroscope(
        selectedSign!,
        birthChart: birthChart,
      );

      if (mounted) {
        setState(() {
          horoscope = result;
          isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Yorum alınamadı', error: e);
      if (mounted) {
        setState(() {
          error = 'Yorum alınamadı';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    final theme = Theme.of(context);

    if (selectedSign == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'Günlük Burç Yorumu',
          showBackButton: false,
          showNotification: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Günlük Burç Yorumu',
        showBackButton: false,
        showNotification: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHoroscope,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Burç Seçici
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.8),
                                theme.colorScheme.secondary
                                    .withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Burcunu Seç',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedSign,
                                    isExpanded: true,
                                    dropdownColor: theme.colorScheme.primary,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    items: const [
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
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null &&
                                          newValue != selectedSign) {
                                        setState(() {
                                          selectedSign = newValue;
                                        });
                                        _loadHoroscope();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (horoscope != null) ...[
                        // Transit Bilgileri
                        if (horoscope!.transitAspects.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_graph,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Günlük Transit Etkileri',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...horoscope!.transitAspects
                                          .map((transit) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.star_border,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${transit.transitPlanet} - ${transit.aspectsToNatal.first.natalPlanet}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${transit.aspectType} (${transit.aspectsToNatal.first.orb.toStringAsFixed(1)}°)',
                                                      style: TextStyle(
                                                        color: theme.colorScheme
                                                            .primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        transit.interpretation),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Şanslı Saatler
                        if (horoscope!.luckyHours.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Şanslı Saatler',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            horoscope!.luckyHours.map((hour) {
                                          return Chip(
                                            label: Text(hour),
                                            backgroundColor: theme
                                                .colorScheme.primaryContainer,
                                            labelStyle: TextStyle(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Günlük Yorum
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Günlük Yorum',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(horoscope!.dailyHoroscope),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Puanlar
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverToBoxAdapter(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.score,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Günlük Puanlar',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildScoreRow(
                                        'Aşk', horoscope!.scores['love'] ?? 5),
                                    _buildScoreRow('Kariyer',
                                        horoscope!.scores['career'] ?? 5),
                                    _buildScoreRow('Para',
                                        horoscope!.scores['money'] ?? 5),
                                    _buildScoreRow('Sağlık',
                                        horoscope!.scores['health'] ?? 5),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Şans Faktörleri
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.stars,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Şans Faktörleri',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (horoscope!.luckNumber != null)
                                      ListTile(
                                        leading: Icon(
                                          Icons.numbers,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: const Text('Şans Sayısı'),
                                        subtitle: Text(horoscope!.luckNumber!),
                                      ),
                                    if (horoscope!.luckColor != null)
                                      ListTile(
                                        leading: Icon(
                                          Icons.color_lens,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: const Text('Şans Rengi'),
                                        subtitle: Text(horoscope!.luckColor!),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$score/10'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}
