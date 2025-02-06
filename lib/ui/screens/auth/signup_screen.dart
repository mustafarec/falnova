import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:falnova/backend/services/preferences_service.dart';

final _logger = Logger();
final _supabase = Supabase.instance.client;

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final isLoading = useState(false);
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final prefsService = ref.watch(preferencesServiceProvider);

    Future<void> signUp() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        _logger.d('Kayıt işlemi başlatılıyor...');

        // Geçici kullanıcı verilerini kaydet
        await prefsService.saveTempUserData({
          'email': emailController.text,
          'password': passwordController.text,
          'first_name': nameController.text,
          'last_name': surnameController.text,
        });

        if (context.mounted) {
          // Doğum bilgileri formuna yönlendir
          context.go('/auth/birth-info');
        }
      } catch (e) {
        _logger.e('Kayıt hatası', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt olurken bir hata oluştu: $e'),
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
                      color: const Color(0xFF9C27B0).withAlpha(26),
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
                      'Adım 1/3: Hesap Bilgileri',
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
                      color: const Color(0xFF9C27B0).withAlpha(26),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // İsim
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'İsim',
                              prefixIcon:
                                  Icon(Icons.person, color: Color(0xFF9C27B0)),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'İsim alanı boş bırakılamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Soyisim
                          TextFormField(
                            controller: surnameController,
                            decoration: const InputDecoration(
                              labelText: 'Soyisim',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: Color(0xFF9C27B0)),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Soyisim alanı boş bırakılamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-posta',
                              prefixIcon:
                                  Icon(Icons.email, color: Color(0xFF9C27B0)),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'E-posta alanı boş bırakılamaz';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Geçerli bir e-posta adresi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color(0xFF9C27B0)),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF9C27B0),
                                ),
                                onPressed: () {
                                  isPasswordVisible.value =
                                      !isPasswordVisible.value;
                                },
                              ),
                            ),
                            obscureText: !isPasswordVisible.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre alanı boş bırakılamaz';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Kayıt Ol Butonu
                          FilledButton.icon(
                            onPressed: isLoading.value ? null : signUp,
                            icon: isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward),
                            label: Text(
                              isLoading.value ? 'Kaydediliyor...' : 'Devam Et',
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Giriş Yap Linki
                    TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: const Text(
                        'Zaten hesabın var mı? Giriş yap',
                        style: TextStyle(color: Color(0xFF9C27B0)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
