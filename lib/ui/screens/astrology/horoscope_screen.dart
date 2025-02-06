import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:falnova/backend/services/astrology/horoscope_service.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

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

class HoroscopeScreen extends HookConsumerWidget {
  final String? selectedHoroscopeId;

  const HoroscopeScreen({
    super.key,
    this.selectedHoroscopeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSign = useState<String>(selectedHoroscopeId ?? 'Koç');
    final isLoading = useState(false);
    final horoscopeText = useState<String>('');
    final birthDate = useState<DateTime?>(null);

    Future<void> getHoroscope(String sign, ValueNotifier<bool> isLoading,
        ValueNotifier<String> horoscopeText, WidgetRef ref) async {
      try {
        isLoading.value = true;
        final horoscope =
            await ref.read(horoscopeServiceProvider).getDailyHoroscope(sign);
        horoscopeText.value = horoscope.dailyHoroscope;
      } catch (e) {
        _logger.e('Yorum alınamadı', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yorum alınırken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> saveBirthDate(DateTime date) async {
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('profiles').update({
            'birth_date': date.toIso8601String(),
          }).eq('id', user.id);

          final zodiacSign = getZodiacSign(date);
          selectedSign.value = zodiacSign;
          getHoroscope(zodiacSign, isLoading, horoscopeText, ref);
        }
      } catch (e) {
        _logger.e('Doğum tarihi kaydedilemedi', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doğum tarihi kaydedilirken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> _selectDate() async {
      final DateTime? picked = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) => DatePickerDialog(
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ),
      );

      if (picked != null) {
        birthDate.value = picked;
        await saveBirthDate(picked);
      }
    }

    useEffect(() {
      Future<void> getUserZodiacSign() async {
        try {
          final user = _supabase.auth.currentUser;
          if (user != null) {
            final userData = await _supabase
                .from('profiles')
                .select('birth_date')
                .eq('id', user.id)
                .single();

            if (userData['birth_date'] != null) {
              final birthDate = DateTime.parse(userData['birth_date']);
              final zodiacSign = getZodiacSign(birthDate);
              selectedSign.value = zodiacSign;
              getHoroscope(zodiacSign, isLoading, horoscopeText, ref);
            } else {
              // Doğum tarihi yoksa tarih seçiciyi göster
              if (context.mounted) {
                _selectDate();
              }
            }
          }
        } catch (e) {
          _logger.e('Burç bilgisi alınamadı', error: e);
          if (context.mounted) {
            _selectDate();
          }
        }
      }

      getUserZodiacSign();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Burç Yorumu'),
        actions: [
          // Doğum tarihini değiştirme butonu
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Doğum Tarihini Değiştir',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Doğum tarihi gösterimi
            if (birthDate.value != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cake, color: Color(0xFF9C27B0)),
                    const SizedBox(width: 8),
                    Text(
                      'Doğum Tarihi: ${DateFormat('dd.MM.yyyy').format(birthDate.value!)}',
                      style: const TextStyle(
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Burç Seçici
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9C27B0),
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSign.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.stars, color: Color(0xFF9C27B0)),
                  labelText: 'Burç Seçin',
                ),
                items: const [
                  DropdownMenuItem(value: 'Koç', child: Text('Koç')),
                  DropdownMenuItem(value: 'Boğa', child: Text('Boğa')),
                  DropdownMenuItem(value: 'İkizler', child: Text('İkizler')),
                  DropdownMenuItem(value: 'Yengeç', child: Text('Yengeç')),
                  DropdownMenuItem(value: 'Aslan', child: Text('Aslan')),
                  DropdownMenuItem(value: 'Başak', child: Text('Başak')),
                  DropdownMenuItem(value: 'Terazi', child: Text('Terazi')),
                  DropdownMenuItem(value: 'Akrep', child: Text('Akrep')),
                  DropdownMenuItem(value: 'Yay', child: Text('Yay')),
                  DropdownMenuItem(value: 'Oğlak', child: Text('Oğlak')),
                  DropdownMenuItem(value: 'Kova', child: Text('Kova')),
                  DropdownMenuItem(value: 'Balık', child: Text('Balık')),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    selectedSign.value = value;
                    getHoroscope(value, isLoading, horoscopeText, ref);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Yorum Gösterimi
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF9C27B0),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Color(0xFF9C27B0),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedSign.value,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9C27B0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              horoscopeText.value,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
