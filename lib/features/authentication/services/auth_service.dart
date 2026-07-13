import '../../../core/network/api_client.dart';
import '../models/auth_token.dart';
import '../models/login_request.dart';

class AuthService {
  const AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<AuthToken> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: request.toJson());
      final data = response.data?['data']['accessToken'];
      return AuthToken.fromJson(data ?? const {});
    } catch (error) {
      print(error);
      throw _apiClient.mapError(error);
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      // final response = await _apiClient.dio.get<Map<String, dynamic>>(
      //   '/api/auth/validate',
      //   options: _apiClient.authOptions(token),
      // );
      // return response.data?['data'] ?? false;
      return true;
    } catch (error) {
      throw _apiClient.mapError(error);
    }
  }
}
