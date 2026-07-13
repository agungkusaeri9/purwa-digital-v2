import 'package:purwa_digital/core/storage/preferences_service.dart';
import 'package:purwa_digital/features/splash/enums/splash_destination.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';

class AuthRepository {
  const AuthRepository(
      this._authService, this._secureStorage, this._preferences);
  final AuthService _authService;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  Future<void> login(LoginRequest request) async {
    final token = await _authService.login(request);
    await _secureStorage.saveToken(token.accessToken);
  }

  Future<SplashDestination> checkSession() async {
    final token = await _secureStorage.readToken();

    if (token != null) {
      final valid = await _authService.validateToken(token);
      if (valid) {
        return SplashDestination.home;
      }

      await _secureStorage.clearToken();
    }

    final seen = await _preferences.hasSeenOnboarding();

    if (seen) {
      return SplashDestination.login;
    }

    return SplashDestination.onboarding;
  }

  Future<void> logout() async {
    await _secureStorage.clearToken();
  }
}
