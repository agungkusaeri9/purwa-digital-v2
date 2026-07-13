import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    _openOnboarding();
  }

  Future<void> _openOnboarding() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    if (mounted) context.go('/onboarding');
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kelola kebutuhan digital Anda\ndengan lebih mudah dan aman.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const Spacer(flex: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'v.1.0.0',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
