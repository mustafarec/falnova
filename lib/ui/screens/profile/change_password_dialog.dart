import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/backend/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Yeni şifreler eşleşmiyor');
      return;
    }

    if (newPassword.length < 8) {
      _showError('Yeni şifre en az 8 karakter olmalıdır');
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw 'Oturum açık değil';
      }

      // Önce mevcut şifreyi kontrol et
      try {
        final response = await supabase.auth.signInWithPassword(
          email: currentUser.email ?? '',
          password: currentPassword,
        );

        if (response.user == null) {
          throw 'Mevcut şifre yanlış';
        }
      } catch (e) {
        if (e.toString().contains('Invalid login credentials')) {
          throw 'Mevcut şifreniz yanlış';
        }
        rethrow;
      }

      // Şifreyi güncelle
      try {
        await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );

        if (mounted) {
          _showSuccess('Şifreniz başarıyla güncellendi');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (e.toString().contains('Auth error')) {
          throw 'Şifre güncellenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
        }
        rethrow;
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isChangingPassword,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Şifre Değiştir',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() =>
                        _obscureCurrentPassword = !_obscureCurrentPassword),
                  ),
                ),
                obscureText: _obscureCurrentPassword,
                enabled: !_isChangingPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
                obscureText: _obscureNewPassword,
                enabled: !_isChangingPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                enabled: !_isChangingPassword,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isChangingPassword
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _isChangingPassword ? null : _handleChangePassword,
                    child: _isChangingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Değiştir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
