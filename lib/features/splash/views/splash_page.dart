import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purwa_digital/features/splash/viewmodels/splash_viewmodel.dart';

import '../viewmodels/splash_state.dart';
import '../viewmodels/splash_viewmodel.dart';
import '../enums/splash_destination.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    Future.microtask(() {
      ref.read(splashViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(
      splashViewModelProvider,
      (previous, next) {
        switch (next.destination) {
          case SplashDestination.home:
            context.go('/home');
            break;

          case SplashDestination.login:
            context.go('/login');
            break;

          case SplashDestination.onboarding:
            context.go('/onboarding');
            break;

          case null:
            break;
        }
      },
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colorScheme.onPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Purwa Digital',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) => LinearProgressIndicator(
                  value: _progressController.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
