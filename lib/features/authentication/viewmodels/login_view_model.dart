import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/splash/enums/splash_destination.dart';

import '../../../core/errors/app_exception.dart';
import '../models/login_request.dart';
import '../providers/auth_providers.dart';

class LoginState {
  const LoginState(
      {this.isSubmitting = false, this.isSuccess = false, this.errorMessage});
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> submit(
      {required String username, required String password}) async {
    state = const LoginState(isSubmitting: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(username: username, password: password));
      state = const LoginState(isSuccess: true);
    } on AppException catch (error) {
      state = LoginState(errorMessage: error.message);
    } catch (_) {
      state = const LoginState(errorMessage: 'Tidak dapat masuk. Coba lagi.');
    }
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
