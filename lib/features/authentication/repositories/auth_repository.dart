import '../../../core/storage/secure_storage_service.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';

class AuthRepository {
  const AuthRepository(this._authService, this._secureStorage);
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  Future<void> login(LoginRequest request) async {
    final token = await _authService.login(request);
    await _secureStorage.saveToken(token.accessToken);
  }
}
