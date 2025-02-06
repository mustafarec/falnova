import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:falnova/backend/services/auth/google_auth_service.dart';

final _logger = Logger();

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final googleAuthService = ref.watch(googleAuthServiceProvider);

    Future<void> signIn() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        _logger.d('Giriş işlemi başlatılıyor...');

        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (response.user != null) {
          _logger.d('Giriş başarılı');
          if (context.mounted) {
            context.go('/');
          }
        }
      } catch (e, stackTrace) {
        _logger.e('Giriş hatası', error: e, stackTrace: stackTrace);
        if (context.mounted) {
          String errorMessage = '';
          if (e.toString().contains('Email not confirmed')) {
            errorMessage = 'Lütfen email adresinizi doğrulayın';
          } else if (e.toString().contains('Invalid login credentials')) {
            errorMessage = 'Hatalı email veya şifre';
          } else {
            errorMessage = 'Giriş yapılırken bir hata oluştu: $e';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ve Başlık
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FalNOVA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Kahve Falı ve Astroloji Platformu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Form Alanları
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // E-posta
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'ornek@email.com',
                            prefixIcon: const Icon(Icons.email,
                                color: Color(0xFF9C27B0)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF9C27B0),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta gerekli';
                            }
                            if (!value.contains('@')) {
                              return 'Geçerli bir e-posta adresi girin';
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
                            hintText: 'En az 6 karakter',
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFF9C27B0)),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF9C27B0),
                                width: 2,
                              ),
                            ),
                          ),
                          obscureText: !isPasswordVisible.value,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => signIn(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giriş Yap Butonu
                  ElevatedButton(
                    onPressed: isLoading.value ? null : signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Kayıt Ol Butonu
                  TextButton(
                    onPressed: () => context.go('/auth/signup'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Hesabın yok mu? ',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Kayıt Ol',
                            style: TextStyle(
                              color: Color(0xFF9C27B0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ayırıcı
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'veya',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Google ile Giriş
                  OutlinedButton.icon(
                    onPressed: isLoading.value
                        ? null
                        : () async {
                            try {
                              isLoading.value = true;
                              final response =
                                  await googleAuthService.signInWithGoogle();
                              if (response != null && context.mounted) {
                                context.go('/');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Google ile giriş yapılırken bir hata oluştu: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF9C27B0)),
                            ),
                          )
                        : Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                          ),
                    label: const Text(
                      'Google ile Devam Et',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
