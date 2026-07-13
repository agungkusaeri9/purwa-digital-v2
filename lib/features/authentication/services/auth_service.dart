import '../../../core/network/api_client.dart';
import '../models/auth_token.dart';
import '../models/login_request.dart';

class AuthService {
  const AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<AuthToken> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio
          .post<Map<String, dynamic>>('/auth/login', data: request.toJson());
      return AuthToken.fromJson(response.data ?? const {});
    } catch (error) {
      throw _apiClient.mapError(error);
    }
  }
}
