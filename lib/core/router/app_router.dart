import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purwa_digital/features/main/view/main_page.dart';

import '../../features/activity/views/activity_page.dart';
import '../../features/authentication/views/login_page.dart';
import '../../features/authentication/views/startup_pin_page.dart';
import '../../features/home/views/home_page.dart';
import '../../features/notification/views/notification_page.dart';
import '../../features/onboarding/views/onboarding_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/settings/views/settings_page.dart';
import '../../features/splash/views/splash_page.dart';
import '../../features/transaction/views/transaction_page.dart';
import '../../features/wallet/views/wallet_page.dart';
import '../../features/ppob/views/pulsa_form_page.dart';
import '../../features/ppob/views/pulsa_brand_page.dart';
import '../../features/ppob/views/data_brand_page.dart';
import '../../features/ppob/views/data_form_page.dart';
import '../../features/ppob/views/pln_menu_page.dart';
import '../../features/ppob/views/pln_form_page.dart';
import '../../features/ppob/views/pln_pasca_form_page.dart';
import '../../features/ppob/views/game_brand_page.dart';
import '../../features/ppob/views/game_form_page.dart';
import '../../features/transaction/models/ppob_transaction_model.dart';
import '../../features/transaction/views/transaction_detail_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.startupPin,
        builder: (_, __) => const StartupPinPage(),
      ),
      GoRoute(
        path: AppRoutes.pulsaForm,
        builder: (context, state) {
          final brand = state.uri.queryParameters['brand'];
          return PulsaFormPage(initialBrand: brand);
        },
      ),
      GoRoute(
        path: AppRoutes.pulsaBrand,
        builder: (_, __) => const PulsaBrandPage(),
      ),
      GoRoute(
        path: AppRoutes.dataBrand,
        builder: (_, __) => const DataBrandPage(),
      ),
      GoRoute(
        path: AppRoutes.dataForm,
        builder: (context, state) {
          final brand = state.uri.queryParameters['brand'];
          return DataFormPage(initialBrand: brand);
        },
      ),
      GoRoute(
        path: AppRoutes.plnMenu,
        builder: (_, __) => const PlnMenuPage(),
      ),
      GoRoute(
        path: AppRoutes.plnForm,
        builder: (_, __) => const PlnFormPage(),
      ),
      GoRoute(
        path: AppRoutes.plnPascaForm,
        builder: (_, __) => const PlnPascaFormPage(),
      ),
      GoRoute(
        path: AppRoutes.gameBrand,
        builder: (_, __) => const GameBrandPage(),
      ),
      GoRoute(
        path: AppRoutes.gameForm,
        builder: (context, state) {
          final brand = state.uri.queryParameters['brand'];
          return GameFormPage(initialBrand: brand);
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetail,
        builder: (context, state) {
          final transaction = state.extra as PPOBTransactionModel;
          return TransactionDetailPage(transaction: transaction);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          /// HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),

          /// TRANSACTION
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (_, __) => const TransactionPage(),
              ),
            ],
          ),

          /// WALLET
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wallet,
                builder: (_, __) => const WalletPage(),
              ),
            ],
          ),

          /// ACTIVITY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activity,
                builder: (_, __) => const ActivityPage(),
              ),
            ],
          ),

          /// PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (_, __) => const NotificationPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);
