import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/authentication/providers/auth_providers.dart';
import 'package:purwa_digital/features/splash/viewmodels/splash_state.dart';

class SplashViewModel extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    final destination = await ref.read(authRepositoryProvider).checkSession();

    final remain = 5 - stopwatch.elapsed.inSeconds;

    if (remain > 0) {
      await Future.delayed(Duration(seconds: remain));
    }

    state = state.copyWith(
      isLoading: false,
      destination: destination,
    );
  }
}

final splashViewModelProvider = NotifierProvider<SplashViewModel, SplashState>(
  SplashViewModel.new,
);
