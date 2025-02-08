import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:falnova/backend/services/preferences_service.dart';
import 'package:falnova/backend/services/notification/index.dart';

final _logger = Logger();
final _supabase = Supabase.instance.client;

class UserPreferencesScreen extends HookConsumerWidget {
  const UserPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCoffeeType = useState<String?>(null);
    final selectedReadingPreference = useState<String>('detailed');
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final prefsService = ref.watch(preferencesServiceProvider);

    Future<void> savePreferences() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        _logger.d('Kullanıcı tercihleri kaydediliyor...');

        // Önce mevcut geçici verileri kontrol et
        final existingData = prefsService.getTempUserData();
        if (existingData == null ||
            existingData['email'] == null ||
            existingData['password'] == null) {
          throw Exception(
              'Gerekli kayıt bilgileri eksik. Lütfen kayıt işlemini baştan başlatın.');
        }

        // Tercihleri kaydet
        final preferences = {
          'favorite_coffee_type': selectedCoffeeType.value,
          'reading_preference': selectedReadingPreference.value,
        };

        await prefsService.updateTempUserData(preferences);

        // Güncel verileri al
        final tempUserData = prefsService.getTempUserData();
        if (tempUserData == null) {
          throw Exception('Geçici kullanıcı verileri bulunamadı');
        }

        // Email ve şifre kontrolü
        final email = tempUserData['email'];
        final password = tempUserData['password'];

        if (email == null || password == null) {
          throw Exception('Email veya şifre bulunamadı');
        }

        // Kullanıcı kaydını oluştur
        final authResponse = await _supabase.auth.signUp(
          email: email.toString(),
          password: password.toString(),
        );

        if (authResponse.user == null) {
          throw Exception('Kullanıcı kaydı oluşturulamadı');
        }

        // Profil bilgilerini hazırla
        final profileData = {
          'id': authResponse.user!.id,
          'first_name': tempUserData['first_name']?.toString(),
          'last_name': tempUserData['last_name']?.toString(),
          'birth_date': tempUserData['birth_date']?.toString(),
          'birth_time': tempUserData['birth_time']?.toString(),
          'birth_city': tempUserData['birth_city']?.toString(),
          'gender': tempUserData['gender']?.toString(),
          'zodiac_sign': tempUserData['zodiac_sign']?.toString(),
          'rising_sign': tempUserData['rising_sign']?.toString(),
          'moon_sign': tempUserData['moon_sign']?.toString(),
          'favorite_coffee_type': selectedCoffeeType.value,
          'reading_preference': selectedReadingPreference.value,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Null değerleri filtrele
        final cleanProfileData = Map<String, dynamic>.fromEntries(
            profileData.entries.where((e) => e.value != null));

        // Profil bilgilerini kaydet
        await _supabase.from('profiles').upsert(cleanProfileData);

        // Geçici verileri temizle
        await prefsService.clearTempUserData();

        // Bildirim servisini yeniden başlat
        try {
          await NotificationService().reinitialize();
        } catch (e) {
          _logger.w('Bildirim servisi başlatılamadı: $e');
        }

        if (context.mounted) {
          context.go('/');
        }
      } catch (e) {
        _logger.e('Kullanıcı tercihleri kaydedilemedi', error: e);

        // Hata durumunda auth kaydını da sil
        try {
          await _supabase.auth.signOut();
        } catch (signOutError) {
          _logger.e('Oturum kapatma hatası', error: signOutError);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt işlemi başarısız oldu: $e'),
              backgroundColor: Colors.red,
            ),
          );
          // Hata durumunda ilk sayfaya geri dön
          context.go('/auth/signup');
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
                      color: Colors.purple.withOpacity(0.1),
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
                        Icons.coffee,
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
                    const Text(
                      'Adım 3/3: Tercihleriniz',
                      style: TextStyle(
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
                      color: Colors.purple.withOpacity(0.1),
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
                        'Size özel bir deneyim için tercihlerinizi belirleyin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Kahve Tercihi
                      DropdownButtonFormField<String>(
                        value: selectedCoffeeType.value,
                        decoration: const InputDecoration(
                          labelText: 'Favori Kahve Türünüz',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.coffee, color: Color(0xFF9C27B0)),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'turkish',
                            child: Text('Türk Kahvesi'),
                          ),
                          DropdownMenuItem(
                            value: 'filter',
                            child: Text('Filtre Kahve'),
                          ),
                          DropdownMenuItem(
                            value: 'espresso',
                            child: Text('Espresso'),
                          ),
                          DropdownMenuItem(
                            value: 'americano',
                            child: Text('Americano'),
                          ),
                        ],
                        onChanged: (value) {
                          selectedCoffeeType.value = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen favori kahve türünüzü seçin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Fal Okuma Tercihi
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
                              'Fal Okuma Tercihiniz',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<String>(
                              title: const Text('Detaylı Yorum'),
                              subtitle:
                                  const Text('Tüm detayları görmek istiyorum'),
                              value: 'detailed',
                              groupValue: selectedReadingPreference.value,
                              activeColor: const Color(0xFF9C27B0),
                              onChanged: (value) {
                                selectedReadingPreference.value = value!;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Özet Yorum'),
                              subtitle: const Text(
                                  'Sadece önemli noktaları görmek istiyorum'),
                              value: 'summary',
                              groupValue: selectedReadingPreference.value,
                              activeColor: const Color(0xFF9C27B0),
                              onChanged: (value) {
                                selectedReadingPreference.value = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      FilledButton.icon(
                        onPressed: isLoading.value ? null : savePreferences,
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
                            : const Icon(Icons.check),
                        label: const Text('Kaydet ve Başla'),
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
