import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/core/router/app_router.dart';
import 'package:purwa_digital/features/home/viewmodels/home_state.dart';
import 'package:purwa_digital/features/home/viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<HomeState>(
      homeViewModelProvider,
      (previous, next) {
        if (next.isLoggedOut) {
          context.go('/login');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ref.watch(homeViewModelProvider).isLoading
            ? const CircularProgressIndicator()
            : const Text('Selamat datang di halaman Home!'),
      ),
    );
  }
}
