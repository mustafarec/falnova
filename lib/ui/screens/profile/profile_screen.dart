import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:falnova/backend/repositories/user/user_repository.dart';
import 'package:falnova/backend/models/user/user_profile.dart';
import 'package:intl/intl.dart';

import 'package:falnova/core/models/city_model.dart';
import 'package:falnova/backend/services/zodiac/zodiac_service.dart';
import 'package:falnova/ui/screens/profile/city_search_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _selectedGender;
  String? _selectedCoffeeType;
  String? _selectedReadingPreference;
  DateTime? _selectedBirthDate;
  String? _risingSign;
  String? _moonSign;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _selectedReadingPreference = 'detailed';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserProfile profile) {
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _selectedGender = profile.gender;
    _selectedCoffeeType = profile.favoriteCoffeeType;
    _selectedReadingPreference = profile.readingPreference;
    _selectedBirthDate = profile.birthDate;
    _risingSign = profile.risingSign;
    _moonSign = profile.moonSign;
    _selectedCity = profile.birthCity;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSaving = true);

      final currentProfile = ref.read(userProfileProvider).value!;
      final zodiacSign = _calculateZodiacSign(_selectedBirthDate);

      // Seçilen şehrin koordinatlarını al
      String? latitude;
      String? longitude;
      if (_selectedCity != null) {
        final selectedCityData = ref.read(citiesProvider).firstWhere(
              (city) => city.name == _selectedCity,
              orElse: () => const City(name: '', region: ''),
            );
        latitude = selectedCityData.latitude;
        longitude = selectedCityData.longitude;
      }

      final updatedProfile = currentProfile.copyWith(
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : currentProfile.firstName,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : currentProfile.lastName,
        gender: _selectedGender ?? currentProfile.gender,
        birthDate: _selectedBirthDate ?? currentProfile.birthDate,
        birthCity: _selectedCity ?? currentProfile.birthCity,
        zodiacSign: zodiacSign ?? currentProfile.zodiacSign,
        favoriteCoffeeType:
            _selectedCoffeeType ?? currentProfile.favoriteCoffeeType,
        readingPreference: _selectedReadingPreference ?? 'detailed',
        risingSign: _risingSign?.trim().isNotEmpty == true
            ? _risingSign?.trim()
            : currentProfile.risingSign,
        moonSign: _moonSign?.trim().isNotEmpty == true
            ? _moonSign?.trim()
            : currentProfile.moonSign,
        latitude: latitude ?? currentProfile.latitude,
        longitude: longitude ?? currentProfile.longitude,
        updatedAt: DateTime.now(),
      );

      await ref.read(userRepositoryProvider).updateProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        // Profil verilerini yenile
        ref.invalidate(userProfileProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await ref.read(userRepositoryProvider).signOut();
      // Çıkış başarılı olduğunda router otomatik olarak login sayfasına yönlendirecek
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                setState(() => _isEditing = false);
              } else {
                final profile = userProfileAsync.value;
                if (profile != null) {
                  _initializeControllers(profile);
                  setState(() => _isEditing = true);
                }
              }
            },
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil bulunamadı'));
          }

          if (_isEditing) {
            return _buildEditForm(context, profile);
          }

          return _buildProfileView(context, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, UserProfile profile) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfilePhoto(context, profile),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Cinsiyet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Erkek')),
                    DropdownMenuItem(value: 'female', child: Text('Kadın')),
                    DropdownMenuItem(value: 'other', child: Text('Diğer')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedBirthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedBirthDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Doğum Tarihi',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: _selectedBirthDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _selectedBirthDate = null),
                            )
                          : null,
                    ),
                    child: Text(
                      _selectedBirthDate != null
                          ? DateFormat('dd.MM.yyyy').format(_selectedBirthDate!)
                          : 'Seçiniz',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCoffeeType,
                  decoration: const InputDecoration(
                    labelText: 'Favori Kahve',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.coffee),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'turkish', child: Text('Türk Kahvesi')),
                    DropdownMenuItem(
                        value: 'filter', child: Text('Filtre Kahve')),
                    DropdownMenuItem(
                        value: 'espresso', child: Text('Espresso')),
                    DropdownMenuItem(
                        value: 'americano', child: Text('Americano')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCoffeeType = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _risingSign,
                  decoration: const InputDecoration(
                    labelText: 'Yükselen Burç',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.arrow_upward),
                  ),
                  onChanged: (value) => _risingSign = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _moonSign,
                  decoration: const InputDecoration(
                    labelText: 'Ay Burcu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.nightlight_round),
                  ),
                  onChanged: (value) => _moonSign = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedReadingPreference,
                  decoration: const InputDecoration(
                    labelText: 'Fal Okuma Tercihi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_bulleted),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'detailed', child: Text('Detaylı Yorum')),
                    DropdownMenuItem(
                        value: 'summary', child: Text('Özet Yorum')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedReadingPreference = value),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final selectedCity = await Navigator.push<City>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CitySearchScreen(),
                      ),
                    );
                    if (selectedCity != null) {
                      setState(() {
                        _selectedCity = selectedCity.name;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Doğum Yeri',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_city,
                          color: Color(0xFF9C27B0)),
                      suffixIcon: _selectedCity != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _selectedCity = null),
                            )
                          : const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedCity ?? 'Seçiniz',
                      style: TextStyle(
                        color: _selectedCity != null ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isSaving)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfile profile) {
    // Burç hesaplamaları için provider'ları izle
    final ascendantSignAsync = ref.watch(ascendantSignProvider(
      birthDate: profile.birthDate ?? DateTime.now(),
      latitude: double.parse(profile.latitude ?? "0"),
      longitude: double.parse(profile.longitude ?? "0"),
    ));

    final moonSignAsync = ref.watch(moonSignProvider(
      birthDate: profile.birthDate ?? DateTime.now(),
    ));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfilePhoto(context, profile),
          const SizedBox(height: 24),

          // Kişisel Bilgiler
          _buildInfoCard(
            title: 'Kişisel Bilgiler',
            children: [
              _buildInfoRow('Ad', profile.firstName ?? '-'),
              _buildInfoRow('Soyad', profile.lastName ?? '-'),
              _buildInfoRow('Cinsiyet', _formatGender(profile.gender)),
              _buildInfoRow(
                'Doğum Tarihi',
                profile.birthDate != null
                    ? DateFormat('dd.MM.yyyy').format(profile.birthDate!)
                    : '-',
              ),
              _buildInfoRow('Doğum Yeri', profile.birthCity ?? '-'),
            ],
          ),
          const SizedBox(height: 16),

          // Astrolojik Bilgiler
          _buildInfoCard(
            title: 'Astrolojik Bilgiler',
            children: [
              _buildInfoRow('Güneş Burcu', profile.zodiacSign ?? '-'),
              _buildInfoRow(
                'Yükselen Burç',
                ascendantSignAsync.when(
                  data: (sign) => sign,
                  loading: () => 'Hesaplanıyor...',
                  error: (_, __) => 'Hesaplanamadı',
                ),
                enabled: false,
              ),
              _buildInfoRow(
                'Ay Burcu',
                moonSignAsync.when(
                  data: (sign) => sign,
                  loading: () => 'Hesaplanıyor...',
                  error: (_, __) => 'Hesaplanamadı',
                ),
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tercihler
          _buildInfoCard(
            title: 'Tercihler',
            children: [
              _buildInfoRow('Favori Kahve',
                  _formatCoffeeType(profile.favoriteCoffeeType)),
              _buildInfoRow('Fal Okuma Tercihi',
                  _formatReadingPreference(profile.readingPreference)),
            ],
          ),
          const SizedBox(height: 24),

          // Çıkış Yap Butonu
          FilledButton.icon(
            onPressed: _handleSignOut,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGender(String? gender) {
    switch (gender) {
      case 'male':
        return 'Erkek';
      case 'female':
        return 'Kadın';
      case 'other':
        return 'Diğer';
      default:
        return '-';
    }
  }

  String _formatCoffeeType(String? type) {
    switch (type) {
      case 'turkish':
        return 'Türk Kahvesi';
      case 'filter':
        return 'Filtre Kahve';
      case 'espresso':
        return 'Espresso';
      case 'americano':
        return 'Americano';
      default:
        return '-';
    }
  }

  String _formatReadingPreference(String? pref) {
    switch (pref) {
      case 'detailed':
        return 'Detaylı Yorum';
      case 'summary':
        return 'Özet Yorum';
      default:
        return '-';
    }
  }

  String? _calculateZodiacSign(DateTime? birthDate) {
    if (birthDate == null) return null;

    final day = birthDate.day;
    final month = birthDate.month;

    switch (month) {
      case 1:
        return day <= 19 ? 'Oğlak' : 'Kova';
      case 2:
        return day <= 18 ? 'Kova' : 'Balık';
      case 3:
        return day <= 20 ? 'Balık' : 'Koç';
      case 4:
        return day <= 19 ? 'Koç' : 'Boğa';
      case 5:
        return day <= 20 ? 'Boğa' : 'İkizler';
      case 6:
        return day <= 20 ? 'İkizler' : 'Yengeç';
      case 7:
        return day <= 22 ? 'Yengeç' : 'Aslan';
      case 8:
        return day <= 22 ? 'Aslan' : 'Başak';
      case 9:
        return day <= 22 ? 'Başak' : 'Terazi';
      case 10:
        return day <= 22 ? 'Terazi' : 'Akrep';
      case 11:
        return day <= 21 ? 'Akrep' : 'Yay';
      case 12:
        return day <= 21 ? 'Yay' : 'Oğlak';
      default:
        return null;
    }
  }

  Widget _buildProfilePhoto(BuildContext context, UserProfile profile) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withAlpha(51),
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey[200],
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () async {
                  // Fotoğraf yükleme işlemi burada yapılacak
                },
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
