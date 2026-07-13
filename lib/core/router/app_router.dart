import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/views/login_page.dart';
import '../../features/home/views/home_page.dart';
import '../../features/notification/views/notification_page.dart';
import '../../features/onboarding/views/onboarding_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/settings/views/settings_page.dart';
import '../../features/splash/views/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(
            path: '/onboarding', builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationPage()),
      ],
    ));
