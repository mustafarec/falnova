import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:falnova/ui/screens/auth/login_screen.dart';
import 'package:falnova/ui/screens/auth/signup_screen.dart';
import 'package:falnova/ui/screens/auth/birth_info_screen.dart';
import 'package:falnova/ui/screens/auth/user_preferences_screen.dart';
import 'package:falnova/ui/screens/home/home_screen.dart';
import 'package:falnova/ui/screens/fortune/fortune_screen.dart';
import 'package:falnova/ui/screens/fortune/fortune_result_screen.dart';
import 'package:falnova/ui/screens/fortune/fortune_history_screen.dart';
import 'package:falnova/ui/screens/astrology/horoscope_screen.dart';
import 'package:falnova/ui/screens/notification/notification_screen.dart';
import 'package:falnova/ui/screens/settings/notification_settings_screen.dart';
import 'package:falnova/ui/screens/settings/settings_screen.dart';
import 'package:falnova/ui/screens/profile/profile_screen.dart';
import 'package:falnova/ui/screens/notification/notifications_screen.dart';
import 'package:falnova/backend/services/auth/google_auth_service.dart';
import 'package:falnova/backend/services/supabase_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Export _rootNavigatorKey
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      // Supabase client'ın hazır olduğundan emin ol
      final supabaseService = ref.watch(supabaseServiceProvider);
      if (!supabaseService.isInitialized) {
        return null; // Client hazır değilse yönlendirme yapma
      }

      final isLoggedIn = supabaseService.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (isLoggedIn) {
        // Kullanıcı giriş yapmışsa zorunlu alanları kontrol et
        final googleAuth = ref.read(googleAuthServiceProvider);
        final hasRequiredFields = await googleAuth
            .checkRequiredFields(supabaseService.currentUser!.id);

        if (!hasRequiredFields &&
            !state.matchedLocation.startsWith('/auth/birth-info') &&
            !state.matchedLocation.startsWith('/auth/preferences')) {
          return '/auth/birth-info';
        }

        if (isAuthRoute) {
          return '/';
        }
      } else if (!isAuthRoute) {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: 'birth-info',
            builder: (context, state) => const BirthInfoScreen(),
          ),
          GoRoute(
            path: 'preferences',
            builder: (context, state) => const UserPreferencesScreen(),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: switch (state.matchedLocation) {
                '/' => 0,
                '/fortune' => 1,
                '/horoscope' => 2,
                '/settings' => 3,
                _ => 0,
              },
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/fortune');
                    break;
                  case 2:
                    context.go('/horoscope');
                    break;
                  case 3:
                    context.go('/settings');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.coffee),
                  label: 'Kahve Falı',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Burçlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Ayarlar',
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/fortune',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FortuneScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
            routes: [
              GoRoute(
                path: 'history',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const FortuneHistoryScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
              GoRoute(
                path: 'reading/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == null) {
                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: const Scaffold(
                        body: Center(
                          child: Text('Geçersiz fal ID\'si'),
                        ),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                    );
                  }
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: FortuneResultScreen(readingId: id),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/horoscope',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HoroscopeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/horoscope/:id',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: HoroscopeScreen(
                selectedHoroscopeId: state.pathParameters['id'],
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
            routes: [
              GoRoute(
                path: 'notifications',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const NotificationSettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
              GoRoute(
                path: 'profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final begin = state.matchedLocation == '/'
                    ? const Offset(-1.0, 0.0)
                    : const Offset(1.0, 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
});
