import 'package:purwa_digital/core/storage/preferences_service.dart';
import 'package:purwa_digital/features/splash/enums/splash_destination.dart';
import 'package:purwa_digital/core/errors/app_exception.dart';

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
    await _secureStorage.saveRefreshToken(token.refreshToken);
  }

  Future<SplashDestination> checkSession() async {
    final token = await _secureStorage.readToken();

    if (token != null && token.isNotEmpty) {
      try {
        final valid = await _authService.validateToken(token);
        if (valid) {
          return SplashDestination.home;
        }
      } catch (e) {
        if (e is AppException && e.statusCode == 401) {
          return SplashDestination.login;
        }
        // If it's a network error or other exception, allow offline access fallback
        return SplashDestination.home;
      }
      return SplashDestination.home;
    }

    final seen = await _preferences.hasSeenOnboarding();

    if (seen) {
      return SplashDestination.login;
    }

    return SplashDestination.onboarding;
  }

  Future<void> logout() async {
    await _secureStorage.clearToken();
    await _secureStorage.clearRefreshToken();
  }
}
