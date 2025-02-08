import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:falnova/backend/services/preferences_service.dart';
import 'package:falnova/backend/services/zodiac/zodiac_service.dart';
import 'package:falnova/backend/models/zodiac/zodiac_sign.dart';
import 'package:falnova/core/models/city_model.dart';

final _logger = Logger();

class BirthInfoScreen extends HookConsumerWidget {
  const BirthInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthDate = useState<DateTime?>(null);
    final birthTime = useState<TimeOfDay?>(null);
    final selectedCity = useState<String?>(null);
    final selectedGender = useState<String?>(null);
    final sunSign = useState<ZodiacSign?>(null);
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final prefsService = ref.watch(preferencesServiceProvider);
    final zodiacService = ref.watch(zodiacServiceProvider);

    // Google kullanıcısı kontrolü
    final isGoogleUser = useState<bool>(false);

    // Başlangıçta kontrol et
    useEffect(() {
      Future.microtask(() async {
        final tempData = prefsService.getTempUserData();
        isGoogleUser.value = tempData?['is_google_user'] ?? false;
      });
      return null;
    }, []);

    // Doğum tarihi değiştiğinde burç hesapla
    useEffect(() {
      if (birthDate.value != null) {
        sunSign.value = zodiacService.calculateSunSign(birthDate.value!);
      }
      return null;
    }, [birthDate.value]);

    Future<void> saveBirthInfo() async {
      if (!formKey.currentState!.validate()) return;
      if (birthDate.value == null ||
          birthTime.value == null ||
          selectedCity.value == null ||
          selectedGender.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm bilgileri doldurun'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        isLoading.value = true;
        _logger.d('Doğum bilgileri kaydediliyor...');

        final DateTime fullBirthDate = DateTime(
          birthDate.value!.year,
          birthDate.value!.month,
          birthDate.value!.day,
          birthTime.value!.hour,
          birthTime.value!.minute,
        );

        // Burçları hesapla
        final sunSign = zodiacService.calculateSunSign(fullBirthDate);

        // Şehir koordinatlarını bul
        final cities = ref.read(citiesProvider);
        final city = cities.firstWhere((c) => c.name == selectedCity.value);
        final latitude = double.parse(city.latitude ?? "0");
        final longitude = double.parse(city.longitude ?? "0");

        final ascendantSignFuture = zodiacService.calculateAscendant(
          fullBirthDate,
          latitude: latitude,
          longitude: longitude,
        );
        final moonSignFuture = zodiacService.calculateMoonSign(fullBirthDate);

        // Burç hesaplamalarının tamamlanmasını bekle
        final ascendantSign = await ascendantSignFuture;
        final moonSign = await moonSignFuture;

        // Geçici verileri güncelle
        final tempData = {
          'birth_date': DateFormat('yyyy-MM-dd').format(birthDate.value!),
          'birth_time':
              '${birthTime.value!.hour.toString().padLeft(2, '0')}:${birthTime.value!.minute.toString().padLeft(2, '0')}:00',
          'birth_city': selectedCity.value,
          'gender': selectedGender.value,
          'zodiac_sign': sunSign.name,
          'rising_sign': ascendantSign,
          'moon_sign': moonSign,
        };

        await prefsService.updateTempUserData(tempData);

        if (context.mounted) {
          context.go('/auth/preferences');
        }
      } catch (e) {
        _logger.e('Doğum bilgileri kaydedilemedi', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bilgiler kaydedilirken bir hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo ve Başlık
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(
                        red: 156,
                        green: 39,
                        blue: 176,
                        alpha: 25,
                      ),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.purple.shade50,
                      child: const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FalNova',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGoogleUser.value
                          ? 'Adım 1/2: Doğum Bilgileri' // Google kullanıcısı için
                          : 'Adım 2/3: Doğum Bilgileri', // Normal kayıt için
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(
                        red: 156,
                        green: 39,
                        blue: 176,
                        alpha: 25,
                      ),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Astrolojik hesaplamalar için doğum bilgilerinizi girin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Doğum Tarihi
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Doğum Tarihi'),
                              subtitle: Text(
                                birthDate.value != null
                                    ? DateFormat('dd.MM.yyyy')
                                        .format(birthDate.value!)
                                    : 'Seçiniz',
                              ),
                              trailing: const Icon(Icons.calendar_today,
                                  color: Color(0xFF9C27B0)),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  birthDate.value = date;
                                }
                              },
                            ),
                            if (sunSign.value != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Burcunuz: ${sunSign.value!.name} ${sunSign.value!.symbol}',
                                      style: const TextStyle(
                                        color: Color(0xFF9C27B0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Doğum Saati
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: ListTile(
                          title: const Text('Doğum Saati'),
                          subtitle: Text(
                            birthTime.value != null
                                ? '${birthTime.value!.hour.toString().padLeft(2, '0')}:${birthTime.value!.minute.toString().padLeft(2, '0')}'
                                : 'Seçiniz',
                          ),
                          trailing: const Icon(Icons.access_time,
                              color: Color(0xFF9C27B0)),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              birthTime.value = time;
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Doğum Yeri
                      DropdownButtonFormField<String>(
                        value: selectedCity.value,
                        decoration: const InputDecoration(
                          labelText: 'Doğum Yeri',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city,
                              color: Color(0xFF9C27B0)),
                        ),
                        items: ref.read(citiesProvider).map((city) {
                          return DropdownMenuItem(
                            value: city.name,
                            child: Text(city.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCity.value = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen doğum yerinizi seçin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cinsiyet Seçimi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cinsiyet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<String>(
                              title: const Text('Kadın'),
                              value: 'female',
                              groupValue: selectedGender.value,
                              activeColor: const Color(0xFF9C27B0),
                              onChanged: (value) {
                                selectedGender.value = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Erkek'),
                              value: 'male',
                              groupValue: selectedGender.value,
                              activeColor: const Color(0xFF9C27B0),
                              onChanged: (value) {
                                selectedGender.value = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Belirtmek İstemiyorum'),
                              value: 'not_specified',
                              groupValue: selectedGender.value,
                              activeColor: const Color(0xFF9C27B0),
                              onChanged: (value) {
                                selectedGender.value = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      FilledButton.icon(
                        onPressed: isLoading.value ? null : saveBirthInfo,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF9C27B0),
                        ),
                        icon: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: const Text('Devam Et'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
