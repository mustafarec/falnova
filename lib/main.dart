import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:falnova/firebase_options.dart';
import 'package:falnova/core/config/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:falnova/core/services/service_registry.dart';
import 'package:falnova/core/providers/initialization_provider.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:falnova/core/services/permission_service.dart';
import 'package:falnova/backend/services/astrology/web_helper.dart'
    if (dart.library.ffi) 'package:falnova/backend/services/astrology/io_helper.dart';

final _logger = Logger();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _logger.d('Arka planda bildirim alındı: ${message.notification?.title}');
}

Future<SharedPreferences> initializeMinimalServices() async {
  try {
    _logger.d('Minimal servisler başlatılıyor...');

    // 1. Flutter binding (en başta olmalı)
    WidgetsFlutterBinding.ensureInitialized();
    _logger.d('Flutter binding başlatıldı');

    // 2. .env (kritik)
    await dotenv.load();
    _logger.d('.env dosyası yüklendi');

    // 3. SharedPreferences (kritik)
    final prefs = await SharedPreferences.getInstance();
    _logger.d('SharedPreferences başlatıldı');

    // 4. Supabase (auth için kritik)
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    _logger.d('Supabase başlatıldı');

    // 5. Swiss Ephemeris başlatma
    await initSweph([
      'assets/ephe/seas_18.se1',
      'assets/ephe/sefstars.txt',
      'assets/ephe/seasnam.txt',
    ]);
    _logger.d('Swiss Ephemeris başlatıldı');

    // Native splash screen'i biraz daha tut
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    _logger.i('Minimal servisler başarıyla başlatıldı');
    return prefs;
  } catch (e, stack) {
    _logger.e('Minimal servisler başlatılırken hata',
        error: e, stackTrace: stack);
    rethrow;
  }
}

Future<void> initializeBackgroundServices() async {
  try {
    _logger.d('Arka plan servisleri başlatılıyor...');

    // 1. Firebase Core (kritik)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _logger.d('Firebase başlatıldı');

    // 2. Firebase Messaging Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _logger.d('Firebase arka plan mesaj işleyicisi ayarlandı');

    _logger.i('Arka plan servisleri başarıyla başlatıldı');
  } catch (e, stack) {
    _logger.e('Arka plan servisleri başlatılırken hata',
        error: e, stackTrace: stack);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService.requestPermissions();
  try {
    // 1. Minimal servisleri başlat
    final prefs = await initializeMinimalServices();

    // 2. Firebase ve diğer arka plan servisleri (kritik)
    await initializeBackgroundServices();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    _logger.e('Uygulama başlatılırken hata', error: e, stackTrace: stack);
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF3E5F5),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kritik hata: $e',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(initializationProvider);

    // Başlatma işlemini tetikle
    if (!initState.isInitialized && !initState.isLoading) {
      Future.microtask(() {
        ref.read(initializationProvider.notifier).initialize();
      });
    }

    // Ana uygulamayı göster (splash screen arkada kalacak)
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FalNOVA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Splash screen'i kapat
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        return Stack(
          children: [
            // Ana sayfa (arkada)
            Positioned.fill(child: child),

            // Yükleme göstergesi (önde)
            if (!initState.isInitialized)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF3E5F5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        if (initState.loadingMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            initState.loadingMessage!,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
