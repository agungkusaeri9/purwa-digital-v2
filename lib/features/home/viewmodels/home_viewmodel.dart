import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/core/errors/app_exception.dart';
import 'package:purwa_digital/features/authentication/providers/auth_providers.dart';
import 'package:purwa_digital/features/home/viewmodels/home_state.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await ref.read(authRepositoryProvider).logout();

      state = state.copyWith(
        isLoading: false,
        isLoggedOut: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Logout gagal.',
      );
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
